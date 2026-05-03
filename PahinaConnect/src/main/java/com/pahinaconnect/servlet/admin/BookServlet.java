package com.pahinaconnect.servlet.admin;

import com.pahinaconnect.dao.AuthorDAO;
import com.pahinaconnect.dao.BookDAO;
import com.pahinaconnect.dao.CategoryDAO;
import com.pahinaconnect.model.Book;
import com.pahinaconnect.util.QRCodeUtil;
import com.pahinaconnect.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@MultipartConfig(maxFileSize = 20 * 1024 * 1024, maxRequestSize = 25 * 1024 * 1024)
public class BookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final AuthorDAO authorDAO = new AuthorDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            req.setAttribute("categories", categoryDAO.getAll());
            req.setAttribute("authors", authorDAO.getAll());

            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("book", bookDAO.findById(id));
                req.setAttribute("editMode", true);
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                bookDAO.deleteBook(id);
                res.sendRedirect(req.getContextPath() + "/admin/books?success=deleted");
                return;
            } else if ("qr".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("book", bookDAO.findById(id));
                req.getRequestDispatcher("/WEB-INF/views/admin/book-qr.jsp").forward(req, res);
                return;
            }
            req.setAttribute("books", bookDAO.getAllBooks());
            req.getRequestDispatcher("/WEB-INF/views/admin/books.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/books.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String uploadDir = getServletContext().getRealPath("/uploads/");
        new File(uploadDir + "covers/").mkdirs();
        new File(uploadDir + "ebooks/").mkdirs();

        try {
            Book book = new Book();

            // Read form fields
            book.setIsbn(getParam(req, "isbn"));
            book.setTitle(getParam(req, "title"));
            try { book.setAuthorId(Integer.parseInt(getParam(req, "authorId"))); } catch (Exception ignored) {}
            try { book.setCategoryId(Integer.parseInt(getParam(req, "categoryId"))); } catch (Exception ignored) {}
            book.setPublisher(getParam(req, "publisher"));
            try { book.setPublicationYear(Integer.parseInt(getParam(req, "publicationYear"))); } catch (Exception ignored) {}
            book.setEdition(getParam(req, "edition"));
            try { book.setTotalCopies(Integer.parseInt(getParam(req, "totalCopies"))); } catch (Exception ignored) { book.setTotalCopies(1); }
            book.setDescription(getParam(req, "description"));
            book.setLocation(getParam(req, "location"));
            String lang = getParam(req, "language");
            book.setLanguage(lang != null && !lang.isEmpty() ? lang : "English");
            try { book.setPages(Integer.parseInt(getParam(req, "pages"))); } catch (Exception ignored) {}

            // Handle file uploads via Part API
            String coverImageName = saveUploadedFile(req, "coverImage", uploadDir + "covers/", "cover_");
            String ebookFileName  = saveUploadedFile(req, "ebookFile",  uploadDir + "ebooks/", "ebook_");

            if (!ValidationUtil.isNotEmpty(book.getTitle())) {
                req.setAttribute("error", "Book title is required.");
                req.setAttribute("categories", categoryDAO.getAll());
                req.setAttribute("authors", authorDAO.getAll());
                req.setAttribute("books", bookDAO.getAllBooks());
                req.getRequestDispatcher("/WEB-INF/views/admin/books.jsp").forward(req, res);
                return;
            }

            if (coverImageName != null) book.setCoverImage(coverImageName);
            if (ebookFileName  != null) book.setEbookFile(ebookFileName);

            String idParam = getParam(req, "bookId");
            if (idParam != null && !idParam.isEmpty()) {
                book.setId(Integer.parseInt(idParam));
                bookDAO.updateBook(book);
                res.sendRedirect(req.getContextPath() + "/admin/books?success=updated");
            } else {
                int newId = bookDAO.addBook(book);
                if (newId > 0) {
                    String qrContent = QRCodeUtil.buildBookQRContent(newId, book.getIsbn(), book.getTitle());
                    String qrDir = getServletContext().getRealPath("/uploads/qrcodes/");
                    new File(qrDir).mkdirs();
                    String qrFile = "qr_" + newId + ".png";
                    QRCodeUtil.saveQRCode(qrContent, qrDir + qrFile, 250, 250);
                    bookDAO.updateQRCode(newId, qrFile);
                }
                res.sendRedirect(req.getContextPath() + "/admin/books?success=added");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to save book: " + e.getMessage());
            try {
                req.setAttribute("categories", categoryDAO.getAll());
                req.setAttribute("authors", authorDAO.getAll());
                req.setAttribute("books", bookDAO.getAllBooks());
            } catch (Exception ignored) {}
            req.getRequestDispatcher("/WEB-INF/views/admin/books.jsp").forward(req, res);
        }
    }

    private String getParam(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        return (val != null) ? val.trim() : null;
    }

    private String saveUploadedFile(HttpServletRequest req, String fieldName,
                                    String dir, String prefix) throws IOException, ServletException {
        Part part = req.getPart(fieldName);
        if (part == null || part.getSize() == 0) return null;

        String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (submittedFileName == null || submittedFileName.isEmpty()) return null;

        String ext = "";
        int dot = submittedFileName.lastIndexOf('.');
        if (dot >= 0) ext = submittedFileName.substring(dot);

        String savedName = prefix + System.currentTimeMillis() + ext;
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, Paths.get(dir + savedName), StandardCopyOption.REPLACE_EXISTING);
        }
        return savedName;
    }
}
