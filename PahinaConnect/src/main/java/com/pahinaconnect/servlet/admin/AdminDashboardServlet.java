package com.pahinaconnect.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.pahinaconnect.dao.BookDAO;
import com.pahinaconnect.dao.BookIssueDAO;
import com.pahinaconnect.dao.UserDAO;

public class AdminDashboardServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final UserDAO userDAO = new UserDAO();
    private final BookIssueDAO issueDAO = new BookIssueDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            issueDAO.updateOverdueStatuses();
            req.setAttribute("totalBooks",     bookDAO.countBooks());
            req.setAttribute("availableBooks", bookDAO.countAvailableBooks());
            req.setAttribute("totalStudents",  userDAO.countStudents());
            req.setAttribute("activeIssues",   issueDAO.countActiveIssues());
            req.setAttribute("overdueIssues",  issueDAO.countOverdueIssues());
            req.setAttribute("totalFines",     issueDAO.getTotalFines());
            req.setAttribute("recentIssues",   issueDAO.getAllActiveIssues());
            req.setAttribute("mostBorrowed",   bookDAO.getMostBorrowed(5));
            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Dashboard error: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, res);
        }
    }
}
