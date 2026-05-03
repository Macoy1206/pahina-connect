package com.pahinaconnect.servlet.student;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Date;

import com.pahinaconnect.dao.UserDAO;
import com.pahinaconnect.model.User;
import com.pahinaconnect.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class StudentProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/student/profile.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("loggedUser");
        String firstName  = req.getParameter("firstName");
        String lastName   = req.getParameter("lastName");
        String middleName = req.getParameter("middleName");
        String phone      = req.getParameter("phone");
        String address    = req.getParameter("address");
        String dob        = req.getParameter("dateOfBirth");
        String gender     = req.getParameter("gender");

        StringBuilder errors = new StringBuilder();
        if (!ValidationUtil.isNotEmpty(firstName))  errors.append("First name is required. ");
        if (!ValidationUtil.isNotEmpty(lastName))   errors.append("Last name is required. ");
        if (!ValidationUtil.isValidPhone(phone))    errors.append("Valid phone number is required. ");
        if (!ValidationUtil.isNotEmpty(address))    errors.append("Address is required. ");

        if (errors.length() > 0) {
            req.setAttribute("error", errors.toString());
            req.getRequestDispatcher("/WEB-INF/views/student/profile.jsp").forward(req, res);
            return;
        }

        try {
            // Handle profile picture upload
            // Save to a persistent folder OUTSIDE the webapp so files survive redeployment
            Part picPart = req.getPart("profilePicture");
            if (picPart != null && picPart.getSize() > 0) {
                String fileName = Paths.get(picPart.getSubmittedFileName()).getFileName().toString();
                String ext = fileName.contains(".") 
                    ? fileName.substring(fileName.lastIndexOf('.')).toLowerCase() : ".jpg";
                if (ext.matches("\\.(jpg|jpeg|png|gif|webp)")) {
                    // Use env var on Railway, fallback to local Tomcat path
                    String envDir = System.getenv("UPLOAD_DIR");
                    String uploadDir = (envDir != null && !envDir.isEmpty())
                        ? envDir + "/profiles/"
                        : "C:\\tomcat10\\apache-tomcat-10.1.28\\pahina_uploads\\profiles\\";
                    new File(uploadDir).mkdirs();
                    // Delete old profile picture file if exists
                    if (user.getProfilePicture() != null && !user.getProfilePicture().isEmpty()) {
                        new File(uploadDir + user.getProfilePicture()).delete();
                    }
                    String savedName = "profile_" + user.getId() + ext;
                    try (InputStream in = picPart.getInputStream()) {
                        Files.copy(in, Paths.get(uploadDir + savedName), StandardCopyOption.REPLACE_EXISTING);
                    }
                    user.setProfilePicture(savedName);
                }
            }

            user.setFirstName(ValidationUtil.sanitize(firstName));
            user.setLastName(ValidationUtil.sanitize(lastName));
            user.setMiddleName(ValidationUtil.sanitize(middleName));
            user.setPhone(phone.trim());
            user.setAddress(ValidationUtil.sanitize(address));
            if (dob != null && !dob.isEmpty()) user.setDateOfBirth(Date.valueOf(dob));
            user.setGender(gender);

            if (userDAO.updateProfile(user)) {
                // Refresh user from database to ensure we have latest data
                User updatedUser = userDAO.findById(user.getId());
                if (updatedUser != null) {
                    req.getSession().setAttribute("loggedUser", updatedUser);
                } else {
                    req.getSession().setAttribute("loggedUser", user);
                }
                req.getSession().setAttribute("success", "Profile updated successfully. Changes will appear everywhere!");
                res.sendRedirect(req.getContextPath() + "/student/profile");
                return;
            } else {
                req.setAttribute("error", "Update failed.");
            }
            req.getRequestDispatcher("/WEB-INF/views/student/profile.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/student/profile.jsp").forward(req, res);
        }
    }
}
