package com.pahinaconnect.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.pahinaconnect.dao.CategoryDAO;
import com.pahinaconnect.model.Category;
import com.pahinaconnect.util.ValidationUtil;

public class CategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                categoryDAO.delete(id);
                res.sendRedirect(req.getContextPath() + "/admin/categories?success=deleted");
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("editCategory", categoryDAO.findById(id));
            }
            req.setAttribute("categories", categoryDAO.getAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String idParam = req.getParameter("categoryId");

        if (!ValidationUtil.isNotEmpty(name)) {
            req.setAttribute("error", "Category name is required.");
            try { req.setAttribute("categories", categoryDAO.getAll()); } catch (Exception ignored) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, res);
            return;
        }

        try {
            Category cat = new Category();
            cat.setName(ValidationUtil.sanitize(name));
            cat.setDescription(ValidationUtil.sanitize(description));

            if (idParam != null && !idParam.isEmpty()) {
                cat.setId(Integer.parseInt(idParam));
                categoryDAO.update(cat);
                res.sendRedirect(req.getContextPath() + "/admin/categories?success=updated");
            } else {
                categoryDAO.add(cat);
                res.sendRedirect(req.getContextPath() + "/admin/categories?success=added");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed: " + e.getMessage());
            try { req.setAttribute("categories", categoryDAO.getAll()); } catch (Exception ignored) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, res);
        }
    }
}
