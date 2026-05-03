package com.pahinaconnect.servlet.admin;

import com.pahinaconnect.dao.*;
import com.pahinaconnect.model.*;
import com.pahinaconnect.util.DBConnection;
import com.pahinaconnect.util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.Calendar;

public class BorrowRequestManageServlet extends HttpServlet {

    private final BorrowRequestDAO requestDAO = new BorrowRequestDAO();
    private final BookDAO bookDAO = new BookDAO();
    private final BookIssueDAO issueDAO = new BookIssueDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            req.setAttribute("pendingRequests", requestDAO.getPendingRequests());
            req.setAttribute("allRequests",     requestDAO.getAllRequests());
            req.setAttribute("pendingCount",    requestDAO.countPending());
            req.getRequestDispatcher("/WEB-INF/views/admin/borrow-requests.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/borrow-requests.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        User admin = (User) req.getSession().getAttribute("loggedUser");

        try {
            int requestId = Integer.parseInt(req.getParameter("requestId"));
            BorrowRequest borrowReq = requestDAO.findById(requestId);

            if (borrowReq == null) {
                res.sendRedirect(req.getContextPath() + "/admin/borrow-requests?error=notfound");
                return;
            }

            if ("approve".equals(action)) {
                handleApprove(req, res, borrowReq, admin);
            } else if ("reject".equals(action)) {
                handleReject(req, res, borrowReq, admin);
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect(req.getContextPath() + "/admin/borrow-requests?error=" +
                java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }

    private void handleApprove(HttpServletRequest req, HttpServletResponse res,
                                BorrowRequest borrowReq, User admin) throws Exception {
        Book book = bookDAO.findById(borrowReq.getBookId());
        User student = userDAO.findById(borrowReq.getStudentId());

        if (book == null || !book.isAvailable()) {
            res.sendRedirect(req.getContextPath() + "/admin/borrow-requests?error=unavailable");
            return;
        }

        String dueDaysParam = req.getParameter("dueDays");
        int dueDays = (dueDaysParam != null && !dueDaysParam.isEmpty()) ? Integer.parseInt(dueDaysParam) : 14;

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, dueDays);
        Timestamp dueDate = new Timestamp(cal.getTimeInMillis());

        // Issue the book transactionally
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean decremented = bookDAO.decrementAvailable(borrowReq.getBookId(), conn);
                if (!decremented) {
                    conn.rollback();
                    res.sendRedirect(req.getContextPath() + "/admin/borrow-requests?error=unavailable");
                    return;
                }

                BookIssue issue = new BookIssue();
                issue.setBookId(borrowReq.getBookId());
                issue.setStudentId(borrowReq.getStudentId());
                issue.setDueDate(dueDate);
                issue.setIssuedBy(admin.getId());
                issue.setNotes("Approved from borrow request #" + borrowReq.getId());
                issueDAO.issueBook(issue, conn);

                requestDAO.approveRequest(borrowReq.getId(), admin.getId());
                conn.commit();

                // Send approval email
                String subject = "Pahina Connect - Borrow Request Approved! 📚";
                String body = buildApprovalEmail(student.getFirstName(), book.getTitle(),
                    dueDate.toString().substring(0, 10));
                EmailUtil.sendEmail(student.getEmail(), subject, body);

                res.sendRedirect(req.getContextPath() + "/admin/borrow-requests?success=approved");
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        }
    }

    private void handleReject(HttpServletRequest req, HttpServletResponse res,
                               BorrowRequest borrowReq, User admin) throws Exception {
        User student = userDAO.findById(borrowReq.getStudentId());
        Book book = bookDAO.findById(borrowReq.getBookId());

        requestDAO.rejectRequest(borrowReq.getId(), admin.getId());

        // Send rejection email
        String subject = "Pahina Connect - Borrow Request Update";
        String body = buildRejectionEmail(student.getFirstName(), book.getTitle());
        EmailUtil.sendEmail(student.getEmail(), subject, body);

        res.sendRedirect(req.getContextPath() + "/admin/borrow-requests?success=rejected");
    }

    private String buildApprovalEmail(String name, String title, String dueDate) {
        return "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f5f0e8;padding:20px'>"
            + "<div style='max-width:600px;margin:auto;background:#fff;border-radius:12px;overflow:hidden'>"
            + "<div style='background:#2C5F2E;padding:30px;text-align:center'>"
            + "<h1 style='color:#F5F0E8;margin:0'>📚 Pahina Connect</h1></div>"
            + "<div style='padding:32px'>"
            + "<h2 style='color:#27AE60'>✅ Borrow Request Approved!</h2>"
            + "<p>Hello <strong>" + name + "</strong>,</p>"
            + "<p>Great news! Your borrow request has been <strong>approved</strong>.</p>"
            + "<div style='background:#E8F8EF;border-left:4px solid #27AE60;padding:16px;border-radius:6px;margin:20px 0'>"
            + "<p style='margin:0'><strong>Book:</strong> " + title + "</p>"
            + "<p style='margin:6px 0 0;color:#C0392B'><strong>Due Date:</strong> " + dueDate + "</p>"
            + "</div>"
            + "<p>Please visit the library to pick up your book. Return it on or before the due date to avoid fines.</p>"
            + "</div>"
            + "<div style='background:#2C5F2E;padding:15px;text-align:center'>"
            + "<p style='color:#97BC62;margin:0;font-size:12px'>© 2024 Pahina Connect Library Management System</p>"
            + "</div></div></body></html>";
    }

    private String buildRejectionEmail(String name, String title) {
        return "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f5f0e8;padding:20px'>"
            + "<div style='max-width:600px;margin:auto;background:#fff;border-radius:12px;overflow:hidden'>"
            + "<div style='background:#2C5F2E;padding:30px;text-align:center'>"
            + "<h1 style='color:#F5F0E8;margin:0'>📚 Pahina Connect</h1></div>"
            + "<div style='padding:32px'>"
            + "<h2 style='color:#C0392B'>Borrow Request Update</h2>"
            + "<p>Hello <strong>" + name + "</strong>,</p>"
            + "<p>Unfortunately, your borrow request for <strong>\"" + title + "\"</strong> could not be approved at this time.</p>"
            + "<p>Please visit the library or contact the librarian for more information.</p>"
            + "</div>"
            + "<div style='background:#2C5F2E;padding:15px;text-align:center'>"
            + "<p style='color:#97BC62;margin:0;font-size:12px'>© 2024 Pahina Connect Library Management System</p>"
            + "</div></div></body></html>";
    }
}
