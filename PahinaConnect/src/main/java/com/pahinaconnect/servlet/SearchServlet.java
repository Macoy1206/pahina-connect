package com.pahinaconnect.servlet;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.pahinaconnect.dao.AuthorDAO;
import com.pahinaconnect.dao.BookDAO;
import com.pahinaconnect.dao.CategoryDAO;
import com.pahinaconnect.model.Book;

public class SearchServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final AuthorDAO authorDAO = new AuthorDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            String query = req.getParameter("q");
            String catParam = req.getParameter("category");
            String authParam = req.getParameter("author");
            String availParam = req.getParameter("available");

            Integer categoryId = (catParam != null && !catParam.isEmpty()) ? Integer.parseInt(catParam) : null;
            Integer authorId   = (authParam != null && !authParam.isEmpty()) ? Integer.parseInt(authParam) : null;
            Boolean available  = "1".equals(availParam) ? true : null;

            List<Book> books = bookDAO.searchBooks(query, categoryId, authorId, available);
            req.setAttribute("books", books);
            req.setAttribute("categories", categoryDAO.getAll());
            req.setAttribute("authors", authorDAO.getAll());
            req.setAttribute("query", query);
            req.setAttribute("selectedCategory", categoryId);
            req.setAttribute("selectedAuthor", authorId);
            req.setAttribute("availableOnly", availParam);
            req.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Search failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(req, res);
        }
    }
}
