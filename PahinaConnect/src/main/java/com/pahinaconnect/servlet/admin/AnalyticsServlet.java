package com.pahinaconnect.servlet.admin;

import com.pahinaconnect.dao.*;
import com.pahinaconnect.util.DBConnection;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class AnalyticsServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final BookIssueDAO issueDAO = new BookIssueDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            issueDAO.updateOverdueStatuses();

            // Summary stats
            req.setAttribute("totalBooks",     bookDAO.countBooks());
            req.setAttribute("totalStudents",  userDAO.countStudents());
            req.setAttribute("activeIssues",   issueDAO.countActiveIssues());
            req.setAttribute("overdueIssues",  issueDAO.countOverdueIssues());
            req.setAttribute("totalFines",     issueDAO.getTotalFines());

            // Most borrowed books
            req.setAttribute("mostBorrowed", bookDAO.getMostBorrowed(10));

            // Monthly issue stats (last 6 months)
            req.setAttribute("monthlyStats", getMonthlyStats());

            // Category distribution
            req.setAttribute("categoryStats", getCategoryStats());

            // Overdue rate
            int total = issueDAO.countActiveIssues();
            int overdue = issueDAO.countOverdueIssues();
            double overdueRate = total > 0 ? (overdue * 100.0 / total) : 0;
            req.setAttribute("overdueRate", String.format("%.1f", overdueRate));

            req.getRequestDispatcher("/WEB-INF/views/admin/analytics.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/analytics.jsp").forward(req, res);
        }
    }

    private List<Map<String, Object>> getMonthlyStats() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(issue_date,'%Y-%m') AS month, COUNT(*) AS count " +
                     "FROM book_issues WHERE issue_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                     "GROUP BY month ORDER BY month";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("month", rs.getString("month"));
                m.put("count", rs.getInt("count"));
                list.add(m);
            }
        }
        return list;
    }

    private List<Map<String, Object>> getCategoryStats() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.name, COUNT(bi.id) AS borrow_count " +
                     "FROM categories c LEFT JOIN books b ON c.id=b.category_id " +
                     "LEFT JOIN book_issues bi ON b.id=bi.book_id " +
                     "GROUP BY c.id ORDER BY borrow_count DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("name", rs.getString("name"));
                m.put("count", rs.getInt("borrow_count"));
                list.add(m);
            }
        }
        return list;
    }
}
