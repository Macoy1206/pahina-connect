package com.pahinaconnect.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.pahinaconnect.dao.BookDAO;
import com.pahinaconnect.model.Book;
import com.pahinaconnect.util.QRCodeUtil;

public class QRCodeServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("generate".equals(action)) {
            generateQR(req, res);
        } else if ("scan".equals(action)) {
            req.getRequestDispatcher("/WEB-INF/views/qr-scan.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // Handle QR scan result from JS
        String qrData = req.getParameter("qrData");
        res.setContentType("application/json");
        PrintWriter out = res.getWriter();
        if (qrData != null && qrData.startsWith("PAHINA_CONNECT|BOOK|")) {
            try {
                String[] parts = qrData.split("\\|");
                String idPart = parts[2]; // ID:X
                int bookId = Integer.parseInt(idPart.split(":")[1]);
                Book book = bookDAO.findById(bookId);
                if (book != null) {
                    out.print("{\"success\":true,\"bookId\":" + book.getId() +
                              ",\"title\":\"" + book.getTitle().replace("\"","\\\"") + "\"" +
                              ",\"isbn\":\"" + book.getIsbn() + "\"" +
                              ",\"available\":" + book.isAvailable() + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Book not found\"}");
                }
            } catch (Exception e) {
                out.print("{\"success\":false,\"message\":\"Invalid QR code\"}");
            }
        } else {
            out.print("{\"success\":false,\"message\":\"Not a Pahina Connect QR code\"}");
        }
    }

    private void generateQR(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            int bookId = Integer.parseInt(req.getParameter("bookId"));
            Book book = bookDAO.findById(bookId);
            if (book == null) { res.sendError(404); return; }

            String content = QRCodeUtil.buildBookQRContent(book.getId(), book.getIsbn(), book.getTitle());
            String base64 = QRCodeUtil.generateQRCodeBase64(content, 250, 250);

            res.setContentType("application/json");
            res.getWriter().print("{\"qr\":\"" + base64 + "\"}");
        } catch (Exception e) {
            res.sendError(500, e.getMessage());
        }
    }
}
