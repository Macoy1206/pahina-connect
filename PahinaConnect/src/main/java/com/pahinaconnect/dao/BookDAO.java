package com.pahinaconnect.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.pahinaconnect.model.Book;
import com.pahinaconnect.util.DBConnection;

public class BookDAO {

    public List<Book> getAllBooks() throws SQLException {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT b.*, a.first_name, a.last_name, c.name AS category_name " +
                     "FROM books b LEFT JOIN authors a ON b.author_id=a.id " +
                     "LEFT JOIN categories c ON b.category_id=c.id " +
                     "WHERE b.is_active=1 ORDER BY b.title";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapBook(rs));
        }
        return list;
    }

    public Book findById(int id) throws SQLException {
        String sql = "SELECT b.*, a.first_name, a.last_name, c.name AS category_name " +
                     "FROM books b LEFT JOIN authors a ON b.author_id=a.id " +
                     "LEFT JOIN categories c ON b.category_id=c.id WHERE b.id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapBook(rs);
        }
        return null;
    }

    public Book findByIsbn(String isbn) throws SQLException {
        String sql = "SELECT b.*, a.first_name, a.last_name, c.name AS category_name " +
                     "FROM books b LEFT JOIN authors a ON b.author_id=a.id " +
                     "LEFT JOIN categories c ON b.category_id=c.id WHERE b.isbn=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, isbn);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapBook(rs);
        }
        return null;
    }

    public int addBook(Book book) throws SQLException {
        String sql = "INSERT INTO books (isbn, title, author_id, category_id, publisher, publication_year, edition, " +
                     "total_copies, available_copies, description, cover_image, ebook_file, location, language, pages) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, book.getIsbn());
            ps.setString(2, book.getTitle());
            ps.setInt(3, book.getAuthorId());
            ps.setInt(4, book.getCategoryId());
            ps.setString(5, book.getPublisher());
            ps.setInt(6, book.getPublicationYear());
            ps.setString(7, book.getEdition());
            ps.setInt(8, book.getTotalCopies());
            ps.setInt(9, book.getTotalCopies());
            ps.setString(10, book.getDescription());
            ps.setString(11, book.getCoverImage());
            ps.setString(12, book.getEbookFile());
            ps.setString(13, book.getLocation());
            ps.setString(14, book.getLanguage() != null ? book.getLanguage() : "English");
            ps.setInt(15, book.getPages());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        }
        return -1;
    }

    public boolean updateBook(Book book) throws SQLException {
        String sql = "UPDATE books SET isbn=?, title=?, author_id=?, category_id=?, publisher=?, publication_year=?, " +
                     "edition=?, total_copies=?, description=?, cover_image=?, ebook_file=?, location=?, language=?, pages=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, book.getIsbn());
            ps.setString(2, book.getTitle());
            ps.setInt(3, book.getAuthorId());
            ps.setInt(4, book.getCategoryId());
            ps.setString(5, book.getPublisher());
            ps.setInt(6, book.getPublicationYear());
            ps.setString(7, book.getEdition());
            ps.setInt(8, book.getTotalCopies());
            ps.setString(9, book.getDescription());
            ps.setString(10, book.getCoverImage());
            ps.setString(11, book.getEbookFile());
            ps.setString(12, book.getLocation());
            ps.setString(13, book.getLanguage());
            ps.setInt(14, book.getPages());
            ps.setInt(15, book.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateQRCode(int bookId, String qrPath) throws SQLException {
        String sql = "UPDATE books SET qr_code=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, qrPath);
            ps.setInt(2, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteBook(int id) throws SQLException {
        String sql = "UPDATE books SET is_active=0 WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean decrementAvailable(int bookId, Connection conn) throws SQLException {
        String sql = "UPDATE books SET available_copies = available_copies - 1 WHERE id=? AND available_copies > 0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean incrementAvailable(int bookId, Connection conn) throws SQLException {
        String sql = "UPDATE books SET available_copies = available_copies + 1 WHERE id=? AND available_copies < total_copies";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Book> searchBooks(String query, Integer categoryId, Integer authorId, Boolean available) throws SQLException {
        List<Book> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT b.*, a.first_name, a.last_name, c.name AS category_name " +
            "FROM books b LEFT JOIN authors a ON b.author_id=a.id " +
            "LEFT JOIN categories c ON b.category_id=c.id WHERE b.is_active=1");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append(" AND (b.title LIKE ? OR b.isbn LIKE ? OR a.first_name LIKE ? OR a.last_name LIKE ?)");
            String q = "%" + query + "%";
            params.add(q); params.add(q); params.add(q); params.add(q);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND b.category_id=?");
            params.add(categoryId);
        }
        if (authorId != null && authorId > 0) {
            sql.append(" AND b.author_id=?");
            params.add(authorId);
        }
        if (available != null && available) {
            sql.append(" AND b.available_copies > 0");
        }
        sql.append(" ORDER BY b.title");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapBook(rs));
        }
        return list;
    }

    public int countBooks() throws SQLException {
        String sql = "SELECT COUNT(*) FROM books WHERE is_active=1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countAvailableBooks() throws SQLException {
        String sql = "SELECT COUNT(*) FROM books WHERE is_active=1 AND available_copies > 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public List<Book> getMostBorrowed(int limit) throws SQLException {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT b.*, a.first_name, a.last_name, c.name AS category_name, COUNT(bi.id) AS borrow_count " +
                     "FROM books b LEFT JOIN authors a ON b.author_id=a.id " +
                     "LEFT JOIN categories c ON b.category_id=c.id " +
                     "LEFT JOIN book_issues bi ON b.id=bi.book_id " +
                     "WHERE b.is_active=1 GROUP BY b.id ORDER BY borrow_count DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapBook(rs));
        }
        return list;
    }

    private Book mapBook(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setId(rs.getInt("id"));
        b.setIsbn(rs.getString("isbn"));
        b.setTitle(rs.getString("title"));
        b.setAuthorId(rs.getInt("author_id"));
        try {
            String fn = rs.getString("first_name");
            String ln = rs.getString("last_name");
            b.setAuthorName((fn != null ? fn : "") + " " + (ln != null ? ln : ""));
        } catch (SQLException ignored) {}
        b.setCategoryId(rs.getInt("category_id"));
        try { b.setCategoryName(rs.getString("category_name")); } catch (SQLException ignored) {}
        b.setPublisher(rs.getString("publisher"));
        b.setPublicationYear(rs.getInt("publication_year"));
        b.setEdition(rs.getString("edition"));
        b.setTotalCopies(rs.getInt("total_copies"));
        b.setAvailableCopies(rs.getInt("available_copies"));
        b.setDescription(rs.getString("description"));
        b.setCoverImage(rs.getString("cover_image"));
        b.setEbookFile(rs.getString("ebook_file"));
        b.setQrCode(rs.getString("qr_code"));
        b.setBarcode(rs.getString("barcode"));
        b.setLocation(rs.getString("location"));
        b.setLanguage(rs.getString("language"));
        b.setPages(rs.getInt("pages"));
        b.setActive(rs.getBoolean("is_active"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        return b;
    }
}
