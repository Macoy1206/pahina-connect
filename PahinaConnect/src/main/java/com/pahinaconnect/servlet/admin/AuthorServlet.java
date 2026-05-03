package com.pahinaconnect.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.pahinaconnect.dao.AuthorDAO;
import com.pahinaconnect.model.Author;
import com.pahinaconnect.util.ValidationUtil;

public class AuthorServlet extends HttpServlet {

    private final AuthorDAO authorDAO = new AuthorDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                authorDAO.delete(id);
                res.sendRedirect(req.getContextPath() + "/admin/authors?success=deleted");
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("editAuthor", authorDAO.findById(id));
            }
            req.setAttribute("authors", authorDAO.getAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/authors.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/authors.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String firstName   = req.getParameter("firstName");
        String lastName    = req.getParameter("lastName");
        String bio         = req.getParameter("bio");
        String nationality = req.getParameter("nationality");
        String idParam     = req.getParameter("authorId");

        if (!ValidationUtil.isNotEmpty(firstName) || !ValidationUtil.isNotEmpty(lastName)) {
            req.setAttribute("error", "First name and last name are required.");
            try { req.setAttribute("authors", authorDAO.getAll()); } catch (Exception ignored) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/authors.jsp").forward(req, res);
            return;
        }

        try {
            Author author = new Author();
            author.setFirstName(ValidationUtil.sanitize(firstName));
            author.setLastName(ValidationUtil.sanitize(lastName));
            author.setBio(ValidationUtil.sanitize(bio));
            author.setNationality(ValidationUtil.sanitize(nationality));

            if (idParam != null && !idParam.isEmpty()) {
                author.setId(Integer.parseInt(idParam));
                authorDAO.update(author);
                res.sendRedirect(req.getContextPath() + "/admin/authors?success=updated");
            } else {
                authorDAO.add(author);
                res.sendRedirect(req.getContextPath() + "/admin/authors?success=added");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed: " + e.getMessage());
            try { req.setAttribute("authors", authorDAO.getAll()); } catch (Exception ignored) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/authors.jsp").forward(req, res);
        }
    }
}
