package com.pahinaconnect.servlet;

import java.io.IOException;
import java.sql.Date;

import com.pahinaconnect.dao.UserDAO;
import com.pahinaconnect.model.User;
import com.pahinaconnect.util.EmailUtil;
import com.pahinaconnect.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String firstName  = req.getParameter("firstName");
        String lastName   = req.getParameter("lastName");
        String middleName = req.getParameter("middleName");
        String suffix     = req.getParameter("suffix");
        String email      = req.getParameter("email");
        String phone      = req.getParameter("phone");
        String address    = req.getParameter("address");
        String dob        = req.getParameter("dateOfBirth");
        String gender     = req.getParameter("gender");
        String password   = req.getParameter("password");
        String confirmPwd = req.getParameter("confirmPassword");

        // Validation
        StringBuilder errors = new StringBuilder();
        if (!ValidationUtil.isNotEmpty(firstName))  errors.append("First name is required. ");
        if (!ValidationUtil.isNotEmpty(lastName))   errors.append("Last name is required. ");
        if (!ValidationUtil.isValidEmail(email))    errors.append("Only Gmail addresses are accepted (e.g. juan@gmail.com). ");
        if (!ValidationUtil.isValidPhone(phone))    errors.append("Valid Philippine phone number is required. No more than 2 consecutive identical digits (e.g. 09192234567). ");
        if (!ValidationUtil.isNotEmpty(address))    errors.append("Address is required. ");
        if (!ValidationUtil.isNotEmpty(dob))        errors.append("Date of birth is required. ");
        if (!ValidationUtil.isNotEmpty(gender))     errors.append("Gender is required. ");
        if (!ValidationUtil.isValidPassword(password))
            errors.append("Password must be at least 8 characters with uppercase, lowercase, number, and special character. ");
        if (!password.equals(confirmPwd))           errors.append("Passwords do not match. ");

        if (errors.length() > 0) {
            req.setAttribute("error", errors.toString());
            req.setAttribute("formData", req.getParameterMap());
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
            return;
        }

        try {
            if (userDAO.emailExists(email.trim())) {
                req.setAttribute("error", "This email is already registered.");
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
                return;
            }

            User user = new User();
            user.setStudentId(ValidationUtil.generateStudentId());
            user.setFirstName(ValidationUtil.sanitize(firstName));
            user.setLastName(ValidationUtil.sanitize(lastName));
            user.setMiddleName(ValidationUtil.sanitize(middleName));
            user.setSuffix(suffix != null ? suffix.trim() : null);
            user.setEmail(email.trim().toLowerCase());
            user.setPhone(phone.trim());
            user.setAddress(ValidationUtil.sanitize(address));
            user.setDateOfBirth(Date.valueOf(dob));
            user.setGender(gender);
            user.setPassword(password);
            user.setRole("student");

            int newId = userDAO.register(user);
            if (newId > 0) {
                // Send welcome email
                EmailUtil.sendWelcomeEmail(user.getEmail(), user.getFirstName(), user.getStudentId());
                req.setAttribute("success", "Registration successful! Your Student ID is: " + user.getStudentId() + ". Please login.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
            } else {
                req.setAttribute("error", "Registration failed. Please try again.");
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "A system error occurred: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
        }
    }
}
