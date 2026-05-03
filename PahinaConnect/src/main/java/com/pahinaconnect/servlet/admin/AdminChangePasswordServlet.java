package com.pahinaconnect.servlet.admin;

import com.pahinaconnect.dao.UserDAO;
import com.pahinaconnect.model.User;
import com.pahinaconnect.util.ValidationUtil;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class AdminChangePasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/admin/change-password.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("loggedUser");
        String currentPwd = req.getParameter("currentPassword");
        String newPwd     = req.getParameter("newPassword");
        String confirmPwd = req.getParameter("confirmPassword");

        if (!ValidationUtil.isValidPassword(newPwd)) {
            req.setAttribute("error", "New password must be at least 8 characters with uppercase, lowercase, number, and special character.");
            req.getRequestDispatcher("/WEB-INF/views/admin/change-password.jsp").forward(req, res);
            return;
        }
        if (!newPwd.equals(confirmPwd)) {
            req.setAttribute("error", "New passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/views/admin/change-password.jsp").forward(req, res);
            return;
        }

        try {
            if (!userDAO.verifyPassword(user.getId(), currentPwd)) {
                req.setAttribute("error", "Current password is incorrect.");
                req.getRequestDispatcher("/WEB-INF/views/admin/change-password.jsp").forward(req, res);
                return;
            }
            userDAO.changePassword(user.getId(), newPwd);
            req.setAttribute("success", "Password changed successfully.");
            req.getRequestDispatcher("/WEB-INF/views/admin/change-password.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/change-password.jsp").forward(req, res);
        }
    }
}
