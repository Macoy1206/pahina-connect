package com.pahinaconnect.servlet.student;

import com.pahinaconnect.dao.BookIssueDAO;
import com.pahinaconnect.model.BookIssue;
import com.pahinaconnect.model.User;
import com.pahinaconnect.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class FinePaymentServlet extends HttpServlet {

    private final BookIssueDAO issueDAO = new BookIssueDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        User student = (User) req.getSession().getAttribute("loggedUser");
        String action = req.getParameter("action");

        if ("pay".equals(action)) {
            try {
                int issueId         = Integer.parseInt(req.getParameter("issueId"));
                String method       = req.getParameter("paymentMethod");
                String notes        = req.getParameter("notes");

                // Validate the issue belongs to this student and has unpaid fine
                BookIssue issue = issueDAO.getIssueById(issueId);
                if (issue == null || issue.getStudentId() != student.getId()) {
                    res.sendRedirect(req.getContextPath() + "/student/my-books?error=Invalid+request");
                    return;
                }

                // Calculate fine amount
                double finePerDay = 5.0, maxFine = 500.0;
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                             "SELECT fine_per_day, max_fine FROM fine_settings LIMIT 1")) {
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        finePerDay = rs.getDouble("fine_per_day");
                        maxFine    = rs.getDouble("max_fine");
                    }
                }

                double fineAmount;
                if (issue.getFineAmount() > 0) {
                    // Already has a recorded fine (returned book)
                    fineAmount = issue.getFineAmount();
                } else {
                    // Still borrowed - calculate from days overdue
                    fineAmount = Math.min(issue.getDaysOverdue() * finePerDay, maxFine);
                }

                if (fineAmount <= 0) {
                    res.sendRedirect(req.getContextPath() + "/student/my-books?error=No+fine+to+pay");
                    return;
                }

                // Generate unique reference number: PC-YYYYMMDD-XXXXXX
                String refNumber = generateRefNumber();

                // Save payment record
                try (Connection conn = DBConnection.getConnection()) {
                    conn.setAutoCommit(false);
                    try {
                        // Insert payment record
                        String insertSql = "INSERT INTO fine_payments (issue_id, student_id, amount, payment_method, reference_number, notes) VALUES (?,?,?,?,?,?)";
                        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                            ps.setInt(1, issueId);
                            ps.setInt(2, student.getId());
                            ps.setDouble(3, fineAmount);
                            ps.setString(4, method);
                            ps.setString(5, refNumber);
                            ps.setString(6, notes != null ? notes : "");
                            ps.executeUpdate();
                        }

                        // Mark fine as paid in book_issues
                        String updateSql = "UPDATE book_issues SET fine_paid=1, fine_amount=? WHERE id=?";
                        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                            ps.setDouble(1, fineAmount);
                            ps.setInt(2, issueId);
                            ps.executeUpdate();
                        }

                        conn.commit();

                        // Redirect to receipt page
                        res.sendRedirect(req.getContextPath() + "/student/fine-payment?action=receipt&ref=" + refNumber);

                    } catch (Exception ex) {
                        conn.rollback();
                        throw ex;
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                res.sendRedirect(req.getContextPath() + "/student/my-books?error=Payment+failed");
            }
            return;
        }

        if ("receipt".equals(action) || req.getMethod().equals("GET")) {
            doGet(req, res);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String ref    = req.getParameter("ref");

        if ("receipt".equals(action) && ref != null) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT fp.*, bi.book_id, b.title AS book_title, b.isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_code, u.email, " +
                     "bi.issue_date, bi.due_date, bi.return_date " +
                     "FROM fine_payments fp " +
                     "JOIN book_issues bi ON fp.issue_id = bi.id " +
                     "JOIN books b ON bi.book_id = b.id " +
                     "JOIN users u ON fp.student_id = u.id " +
                     "WHERE fp.reference_number = ?")) {
                ps.setString(1, ref);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    req.setAttribute("refNumber",     rs.getString("reference_number"));
                    req.setAttribute("bookTitle",     rs.getString("book_title"));
                    req.setAttribute("isbn",          rs.getString("isbn"));
                    req.setAttribute("studentName",   rs.getString("first_name") + " " + rs.getString("last_name"));
                    req.setAttribute("studentCode",   rs.getString("student_code"));
                    req.setAttribute("studentEmail",  rs.getString("email"));
                    req.setAttribute("amount",        rs.getDouble("amount"));
                    req.setAttribute("paymentMethod", rs.getString("payment_method"));
                    req.setAttribute("paidAt",        rs.getTimestamp("paid_at"));
                    req.setAttribute("issueDate",     rs.getTimestamp("issue_date"));
                    req.setAttribute("dueDate",       rs.getTimestamp("due_date"));
                    req.setAttribute("returnDate",    rs.getTimestamp("return_date"));
                    req.getRequestDispatcher("/WEB-INF/views/student/payment-receipt.jsp").forward(req, res);
                    return;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        res.sendRedirect(req.getContextPath() + "/student/my-books");
    }

    private String generateRefNumber() {
        String date = new SimpleDateFormat("yyyyMMdd").format(new Date());
        String rand = String.format("%06d", (int)(Math.random() * 1000000));
        return "PC-" + date + "-" + rand;
    }
}
