package com.pahinaconnect.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

import com.pahinaconnect.dao.BookDAO;
import com.pahinaconnect.model.Book;
import com.pahinaconnect.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class EbookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("view".equals(action)) {
            viewEbook(req, res);
        } else if ("download".equals(action)) {
            downloadEbook(req, res);
        }
    }

    private void viewEbook(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            int bookId = Integer.parseInt(req.getParameter("bookId"));
            Book book = bookDAO.findById(bookId);
            if (book == null || book.getEbookFile() == null) {
                req.setAttribute("error", "E-book not available.");
                req.getRequestDispatcher("/WEB-INF/views/ebook-viewer.jsp").forward(req, res);
                return;
            }
            req.setAttribute("book", book);
            req.getRequestDispatcher("/WEB-INF/views/ebook-viewer.jsp").forward(req, res);
        } catch (Exception e) {
            res.sendError(500);
        }
    }

    private void downloadEbook(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        try {
            int bookId = Integer.parseInt(req.getParameter("bookId"));
            Book book = bookDAO.findById(bookId);
            if (book == null || book.getEbookFile() == null) {
                res.sendError(404, "E-book not found");
                return;
            }
            String uploadDir = getServletContext().getRealPath("/uploads/ebooks/");
            File file = new File(uploadDir + book.getEbookFile());
            if (!file.exists()) { res.sendError(404); return; }

            // Build a safe download filename from the book title
            String safeTitle = book.getTitle().replaceAll("[^a-zA-Z0-9\\s]", "").trim().replaceAll("\\s+", "_");
            String ext = book.getEbookFile().endsWith(".html") ? ".html" : ".pdf";
            String downloadName = safeTitle + ext;

            String contentType = book.getEbookFile().endsWith(".html")
                    ? "text/html; charset=UTF-8"
                    : "application/pdf";

            res.setContentType(contentType);
            res.setHeader("Content-Disposition", "attachment; filename=\"" + downloadName + "\"");
            res.setContentLengthLong(file.length());
            try (FileInputStream fis = new FileInputStream(file);
                 OutputStream out = res.getOutputStream()) {
                byte[] buf = new byte[4096];
                int n;
                while ((n = fis.read(buf)) != -1) out.write(buf, 0, n);
            }
        } catch (Exception e) {
            res.sendError(500);
        }
    }
}
