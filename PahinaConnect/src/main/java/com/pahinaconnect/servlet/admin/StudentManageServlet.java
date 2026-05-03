package com.pahinaconnect.servlet.admin;

import java.io.IOException;

import com.pahinaconnect.dao.BookIssueDAO;
import com.pahinaconnect.dao.BorrowRequestDAO;
import com.pahinaconnect.dao.UserDAO;
import com.pahinaconnect.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class StudentManageServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final BookIssueDAO issueDAO = new BookIssueDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String searchQuery = req.getParameter("q");
        try {
            if ("toggle".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                userDAO.toggleStudentStatus(id);
                res.sendRedirect(req.getContextPath() + "/admin/students?success=updated");
                return;
            }
            if ("view".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                User student = userDAO.findById(id);
                req.setAttribute("student", student);
                req.setAttribute("issues", issueDAO.getAllIssuesByStudent(id));
                BorrowRequestDAO borrowRequestDAO = new BorrowRequestDAO();
                req.setAttribute("borrowRequests", borrowRequestDAO.getByStudent(id));
                req.getRequestDispatcher("/WEB-INF/views/admin/student-detail.jsp").forward(req, res);
                return;
            }

            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                // JSON autocomplete response
                if ("json".equals(req.getParameter("format"))) {
                    java.util.List<User> results = userDAO.searchStudents(searchQuery.trim());
                    StringBuilder json = new StringBuilder("[");
                    for (int i = 0; i < results.size(); i++) {
                        User u = results.get(i);
                        if (i > 0) json.append(",");
                        json.append("{")
                            .append("\"id\":").append(u.getId()).append(",")
                            .append("\"studentId\":\"").append(u.getStudentId()).append("\",")
                            .append("\"name\":\"").append(u.getFullName().replace("\"", "\\\"")).append("\",")
                            .append("\"email\":\"").append(u.getEmail()).append("\",")
                            .append("\"profilePicture\":\"").append(u.getProfilePicture() != null ? u.getProfilePicture() : "").append("\"")
                            .append("}");
                    }
                    json.append("]");
                    res.setContentType("application/json");
                    res.setCharacterEncoding("UTF-8");
                    res.getWriter().write(json.toString());
                    return;
                }
                req.setAttribute("students", userDAO.searchStudents(searchQuery.trim()));
                req.setAttribute("searchQuery", searchQuery);
            } else {
                req.setAttribute("students", userDAO.getAllStudents());
            }
            req.getRequestDispatcher("/WEB-INF/views/admin/students.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/students.jsp").forward(req, res);
        }
    }
}
