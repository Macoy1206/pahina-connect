package com.pahinaconnect.servlet;

import java.io.IOException;

import com.pahinaconnect.dao.BookDAO;
import com.pahinaconnect.dao.BorrowRequestDAO;
import com.pahinaconnect.model.Book;
import com.pahinaconnect.model.User;
import com.pahinaconnect.util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class BorrowRequestServlet extends HttpServlet {

    private static final int MAX_BORROWS = 3;

    private final BorrowRequestDAO requestDAO = new BorrowRequestDAO();
    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { res.sendError(401); return; }

        String action = req.getParameter("action");
        if ("checkLimit".equals(action)) {
            try {
                int used = requestDAO.countActiveBorrowsAndPending(user.getId());
                res.setContentType("application/json");
                res.getWriter().write("{\"used\":" + used + ",\"limit\":" + MAX_BORROWS + "}");
            } catch (Exception e) {
                res.setContentType("application/json");
                res.getWriter().write("{\"used\":0,\"limit\":" + MAX_BORROWS + "}");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { res.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");

        try {
            if ("request".equals(action)) {
                handleRequest(req, res, user);
            } else if ("cancel".equals(action)) {
                handleCancel(req, res, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Operation failed: " + e.getMessage());
            res.sendRedirect(req.getContextPath() + "/student/my-books");
        }
    }

    private void handleRequest(HttpServletRequest req, HttpServletResponse res, User user)
            throws Exception {
        int bookId = Integer.parseInt(req.getParameter("bookId"));
        String notes = req.getParameter("notes");
        String preferredReturnStr = req.getParameter("preferredReturnDate");
        Book book = bookDAO.findById(bookId);

        if (book == null) {
            req.getSession().setAttribute("errorMsg", "Book not found.");
            res.sendRedirect(req.getContextPath() + "/search");
            return;
        }

        // Validate preferred return date
        java.sql.Date preferredReturnDate = null;
        if (preferredReturnStr != null && !preferredReturnStr.trim().isEmpty()) {
            try {
                java.time.LocalDate parsed = java.time.LocalDate.parse(preferredReturnStr);
                java.time.LocalDate today = java.time.LocalDate.now();
                java.time.LocalDate maxDate = today.plusDays(30);
                if (parsed.isBefore(today.plusDays(1))) {
                    req.getSession().setAttribute("errorMsg", "Preferred return date must be at least tomorrow.");
                    res.sendRedirect(req.getContextPath() + "/search");
                    return;
                }
                if (parsed.isAfter(maxDate)) {
                    req.getSession().setAttribute("errorMsg", "Preferred return date cannot exceed 30 days from today.");
                    res.sendRedirect(req.getContextPath() + "/search");
                    return;
                }
                preferredReturnDate = java.sql.Date.valueOf(parsed);
            } catch (Exception e) {
                req.getSession().setAttribute("errorMsg", "Invalid return date format.");
                res.sendRedirect(req.getContextPath() + "/search");
                return;
            }
        } else {
            // Default: 14 days from today
            preferredReturnDate = java.sql.Date.valueOf(java.time.LocalDate.now().plusDays(14));
        }

        // Check 3-book limit
        int currentCount = requestDAO.countActiveBorrowsAndPending(user.getId());
        if (currentCount >= MAX_BORROWS) {
            req.getSession().setAttribute("errorMsg",
                "You have reached the maximum of " + MAX_BORROWS + " books. Please return a book before borrowing another.");
            res.sendRedirect(req.getContextPath() + "/search");
            return;
        }

        // Check if already borrowed
        if (requestDAO.hasActiveBorrow(bookId, user.getId())) {
            req.getSession().setAttribute("errorMsg", "You already have this book borrowed.");
            res.sendRedirect(req.getContextPath() + "/search");
            return;
        }

        // Check if already requested
        if (requestDAO.hasPendingRequest(bookId, user.getId())) {
            req.getSession().setAttribute("errorMsg", "You already have a pending request for \"" + book.getTitle() + "\".");
            res.sendRedirect(req.getContextPath() + "/search");
            return;
        }

        boolean ok = requestDAO.submitRequest(bookId, user.getId(), notes, preferredReturnDate);
        if (ok) {
            String dueDateStr = new java.text.SimpleDateFormat("MMMM dd, yyyy").format(preferredReturnDate);
            String subject = "📚 Pahina Connect - Borrow Request Submitted";
            String body = buildRequestEmail(user.getFirstName(), book.getTitle(), book.getIsbn(), dueDateStr);
            EmailUtil.sendEmail(user.getEmail(), subject, body);

            req.getSession().setAttribute("successMsg",
                "✅ Borrow request for \"" + book.getTitle() + "\" submitted! Preferred return: " + dueDateStr + ". Waiting for admin approval.");
        } else {
            req.getSession().setAttribute("errorMsg", "Failed to submit request. Please try again.");
        }
        res.sendRedirect(req.getContextPath() + "/student/my-books");
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse res, User user)
            throws Exception {
        int requestId = Integer.parseInt(req.getParameter("requestId"));
        boolean ok = requestDAO.cancelRequest(requestId, user.getId());
        if (ok) {
            req.getSession().setAttribute("successMsg", "Borrow request cancelled.");
        } else {
            req.getSession().setAttribute("errorMsg", "Could not cancel request.");
        }
        res.sendRedirect(req.getContextPath() + "/student/my-books");
    }

    private String buildRequestEmail(String name, String title, String isbn, String preferredReturnDate) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
            + "<body style='margin:0;padding:0;background:#EDE5D8;font-family:\"Segoe UI\",Arial,sans-serif'>"
            + "<table width='100%' cellpadding='0' cellspacing='0'><tr><td align='center' style='padding:40px 20px'>"
            + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 8px 40px rgba(27,58,107,0.18)'>"
            + "<tr><td style='background:linear-gradient(135deg,#0F2347,#1B3A6B);padding:36px 40px;text-align:center'>"
            + "<div style='font-size:52px;margin-bottom:10px'>📚</div>"
            + "<h1 style='color:#F8F4EE;margin:0;font-size:26px;font-weight:800'>Pahina Connect</h1>"
            + "<p style='color:rgba(248,244,238,0.75);margin:5px 0 0;font-size:13px'>Library Management System</p>"
            + "</td></tr>"
            + "<tr><td style='background:#1B3A6B;padding:10px 40px;text-align:center'>"
            + "<p style='margin:0;color:#C8A96E;font-size:12px;letter-spacing:1.5px;text-transform:uppercase;font-weight:600'>Borrow Request Submitted</p>"
            + "</td></tr>"
            + "<tr><td style='padding:36px 40px'>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 20px'>Hello <strong style='color:#0F2347'>" + name + "</strong>,</p>"
            + "<p style='color:#3D5070;font-size:15px;line-height:1.7;margin:0 0 24px'>Your borrow request has been submitted and is now <strong>pending admin approval</strong>. You will be notified once it is reviewed.</p>"
            + "<div style='background:#F8F4EE;border:1.5px solid #DDD0BC;border-radius:12px;overflow:hidden;margin:0 0 24px'>"
            + "<div style='background:#1B3A6B;padding:12px 20px'><p style='margin:0;color:#C8A96E;font-size:11px;text-transform:uppercase;letter-spacing:2px;font-weight:700'>Request Details</p></div>"
            + "<div style='padding:20px'>"
            + "<table width='100%' cellpadding='0' cellspacing='0'>"
            + "<tr><td style='padding:8px 0;border-bottom:1px solid #DDD0BC;color:#7A8FA8;font-size:13px;width:40%'>Book Title</td>"
            + "<td style='padding:8px 0;border-bottom:1px solid #DDD0BC;font-weight:700;color:#0F2347'>" + title + "</td></tr>"
            + "<tr><td style='padding:8px 0;border-bottom:1px solid #DDD0BC;color:#7A8FA8;font-size:13px'>ISBN</td>"
            + "<td style='padding:8px 0;border-bottom:1px solid #DDD0BC;font-family:monospace;color:#3D5070'>" + isbn + "</td></tr>"
            + "<tr><td style='padding:8px 0;border-bottom:1px solid #DDD0BC;color:#7A8FA8;font-size:13px'>Preferred Return</td>"
            + "<td style='padding:8px 0;border-bottom:1px solid #DDD0BC;font-weight:700;color:#C0392B'>" + preferredReturnDate + "</td></tr>"
            + "<tr><td style='padding:8px 0;color:#7A8FA8;font-size:13px'>Status</td>"
            + "<td style='padding:8px 0;font-weight:700;color:#C8A96E'>⏳ Pending Admin Approval</td></tr>"
            + "</table></div></div>"
            + "<div style='background:#FBF5E8;border-left:4px solid #C8A96E;border-radius:0 8px 8px 0;padding:14px 18px'>"
            + "<p style='margin:0;color:#A8893E;font-size:13px;font-weight:600'>📍 Next Steps</p>"
            + "<p style='margin:6px 0 0;color:#7A8FA8;font-size:13px;line-height:1.6'>Once approved, please visit the library to pick up your book. A fine of <strong>₱5.00 per day</strong> applies for late returns.</p>"
            + "</div>"
            + "</td></tr>"
            + "<tr><td style='background:#0F2347;padding:24px 40px;text-align:center'>"
            + "<p style='color:#C8A96E;margin:0 0 4px;font-size:13px;font-weight:600'>📚 Pahina Connect Library</p>"
            + "<p style='color:rgba(248,244,238,0.4);margin:0;font-size:11px'>This is an automated message — please do not reply.</p>"
            + "</td></tr></table></td></tr></table></body></html>";
    }
}
