package com.pahinaconnect.servlet;

import java.io.IOException;

import com.pahinaconnect.dao.UserDAO;
import com.pahinaconnect.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // Prevent browser from caching the login page
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, private");
        res.setHeader("Pragma", "no-cache");
        res.setHeader("Expires", "0");

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loggedUser") != null) {
            User u = (User) session.getAttribute("loggedUser");
            redirectByRole(u, req, res);
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
            return;
        }

        try {
            User user = userDAO.findByEmail(email.trim());
            if (user == null || !userDAO.authenticate(email.trim(), password)) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
                return;
            }
            if (!user.isActive()) {
                req.setAttribute("error", "Your account has been deactivated. Please contact the administrator.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
                return;
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedUser", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userRole", user.getRole());
            redirectByRole(user, req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "A system error occurred. Please try again.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
        }
    }

    private void redirectByRole(User user, HttpServletRequest req, HttpServletResponse res) throws IOException {
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty() && !redirect.contains("login")) {
            res.sendRedirect(redirect);
        } else if ("admin".equals(user.getRole())) {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else {
            res.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }
}
