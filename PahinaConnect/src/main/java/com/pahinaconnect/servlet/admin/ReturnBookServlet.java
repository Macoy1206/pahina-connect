package com.pahinaconnect.servlet.admin;

import com.pahinaconnect.dao.*;
import com.pahinaconnect.model.*;
import com.pahinaconnect.util.DBConnection;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class ReturnBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final UserDAO userDAO = new UserDAO();
    private final BookIssueDAO issueDAO = new BookIssueDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            issueDAO.updateOverdueStatuses();
            req.setAttribute("activeIssues", issueDAO.getAllActiveIssues());

            // Fine settings
            String sql = "SELECT fine_per_day, max_fine FROM fine_settings LIMIT 1";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    req.setAttribute("finePerDay", rs.getDouble("fine_per_day"));
                    req.setAttribute("maxFine", rs.getDouble("max_fine"));
                }
            }
            req.getRequestDispatcher("/WEB-INF/views/admin/return-book.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/return-book.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String issueIdParam = req.getParameter("issueId");
        String finePaidParam = req.getParameter("finePaid");

        try {
            int issueId = Integer.parseInt(issueIdParam);
            BookIssue issue = issueDAO.findById(issueId);
            if (issue == null) {
                req.setAttribute("error", "Issue record not found.");
                req.setAttribute("activeIssues", issueDAO.getAllActiveIssues());
                req.getRequestDispatcher("/WEB-INF/views/admin/return-book.jsp").forward(req, res);
                return;
            }

            // Calculate fine
            double finePerDay = 5.0;
            double maxFine = 500.0;
            String fineSql = "SELECT fine_per_day, max_fine FROM fine_settings LIMIT 1";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fineSql)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    finePerDay = rs.getDouble("fine_per_day");
                    maxFine = rs.getDouble("max_fine");
                }
            }

            double fine = 0;
            if (issue.isOverdue()) {
                fine = Math.min(issue.getDaysOverdue() * finePerDay, maxFine);
            }
            boolean finePaid = "true".equals(finePaidParam) || fine == 0;

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    issueDAO.returnBook(issueId, fine, finePaid);
                    bookDAO.incrementAvailable(issue.getBookId(), conn);
                    conn.commit();
                    res.sendRedirect(req.getContextPath() + "/admin/return-book?success=returned");
                } catch (Exception ex) {
                    conn.rollback();
                    throw ex;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Return failed: " + e.getMessage());
            try { req.setAttribute("activeIssues", issueDAO.getAllActiveIssues()); } catch (Exception ignored) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/return-book.jsp").forward(req, res);
        }
    }
}
