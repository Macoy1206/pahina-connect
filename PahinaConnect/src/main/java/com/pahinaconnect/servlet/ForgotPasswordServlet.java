package com.pahinaconnect.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.pahinaconnect.dao.UserDAO;
import com.pahinaconnect.model.User;
import com.pahinaconnect.util.EmailUtil;
import com.pahinaconnect.util.ValidationUtil;

public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String step = req.getParameter("step");
        if (step == null) step = "1";
        req.setAttribute("step", step);
        req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("sendOtp".equals(action)) {
                handleSendOtp(req, res);
            } else if ("verifyOtp".equals(action)) {
                handleVerifyOtp(req, res);
            } else if ("resetPassword".equals(action)) {
                handleResetPassword(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "A system error occurred.");
            req.setAttribute("step", "1");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
        }
    }

    private void handleSendOtp(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        String email = req.getParameter("email");
        if (!ValidationUtil.isValidEmail(email)) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.setAttribute("step", "1");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
            return;
        }
        User user = userDAO.findByEmail(email.trim());
        if (user == null) {
            req.setAttribute("error", "No account found with that email.");
            req.setAttribute("step", "1");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
            return;
        }
        String otp = ValidationUtil.generateOTP();
        userDAO.saveOTP(email.trim(), otp);
        EmailUtil.sendOTP(email.trim(), user.getFirstName(), otp);

        req.getSession().setAttribute("resetEmail", email.trim());
        req.setAttribute("step", "2");
        req.setAttribute("success", "OTP sent to your email. Please check your inbox.");
        req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
    }

    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        String email = (String) req.getSession().getAttribute("resetEmail");
        String otp = req.getParameter("otp");
        if (email == null || otp == null || otp.trim().isEmpty()) {
            req.setAttribute("error", "Session expired. Please start again.");
            req.setAttribute("step", "1");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
            return;
        }
        if (!userDAO.verifyOTP(email, otp.trim())) {
            req.setAttribute("error", "Invalid or expired OTP.");
            req.setAttribute("step", "2");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
            return;
        }
        req.getSession().setAttribute("otpVerified", true);
        req.setAttribute("step", "3");
        req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
    }

    private void handleResetPassword(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        String email = (String) req.getSession().getAttribute("resetEmail");
        Boolean verified = (Boolean) req.getSession().getAttribute("otpVerified");
        String newPwd = req.getParameter("newPassword");
        String confirmPwd = req.getParameter("confirmPassword");

        if (email == null || !Boolean.TRUE.equals(verified)) {
            req.setAttribute("error", "Session expired. Please start again.");
            req.setAttribute("step", "1");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
            return;
        }
        if (!ValidationUtil.isValidPassword(newPwd)) {
            req.setAttribute("error", "Password must be at least 8 characters with uppercase, lowercase, number, and special character.");
            req.setAttribute("step", "3");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
            return;
        }
        if (!newPwd.equals(confirmPwd)) {
            req.setAttribute("error", "Passwords do not match.");
            req.setAttribute("step", "3");
            req.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(req, res);
            return;
        }
        userDAO.resetPassword(email, newPwd);
        req.getSession().removeAttribute("resetEmail");
        req.getSession().removeAttribute("otpVerified");
        req.setAttribute("success", "Password reset successfully! You can now login.");
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
    }
}
