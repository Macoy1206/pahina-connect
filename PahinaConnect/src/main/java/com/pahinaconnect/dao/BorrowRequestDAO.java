package com.pahinaconnect.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.pahinaconnect.model.BorrowRequest;
import com.pahinaconnect.util.DBConnection;

public class BorrowRequestDAO {

    private static final String BASE_SELECT =
        "SELECT br.*, b.title AS book_title, b.isbn AS book_isbn, " +
        "u.first_name, u.last_name, u.student_id AS student_id_code, u.email AS student_email " +
        "FROM borrow_requests br " +
        "JOIN books b ON br.book_id = b.id " +
        "JOIN users u ON br.student_id = u.id ";

    public boolean submitRequest(int bookId, int studentId, String notes, java.sql.Date preferredReturnDate) throws SQLException {
        // Check if student already has a pending request for this book
        String checkSql = "SELECT id FROM borrow_requests WHERE book_id=? AND student_id=? AND status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            if (ps.executeQuery().next()) return false;
        }

        String sql = "INSERT INTO borrow_requests (book_id, student_id, notes, preferred_return_date) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            ps.setString(3, notes);
            ps.setDate(4, preferredReturnDate);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean cancelRequest(int requestId, int studentId) throws SQLException {
        String sql = "UPDATE borrow_requests SET status='cancelled' WHERE id=? AND student_id=? AND status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean approveRequest(int requestId, int adminId) throws SQLException {
        String sql = "UPDATE borrow_requests SET status='approved', reviewed_by=?, reviewed_at=NOW() WHERE id=? AND status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean rejectRequest(int requestId, int adminId) throws SQLException {
        String sql = "UPDATE borrow_requests SET status='rejected', reviewed_by=?, reviewed_at=NOW() WHERE id=? AND status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminId);
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    public BorrowRequest findById(int id) throws SQLException {
        String sql = BASE_SELECT + "WHERE br.id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        }
        return null;
    }

    public List<BorrowRequest> getByStudent(int studentId) throws SQLException {
        List<BorrowRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE br.student_id=? ORDER BY br.requested_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<BorrowRequest> getPendingRequests() throws SQLException {
        List<BorrowRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE br.status='pending' ORDER BY br.requested_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<BorrowRequest> getAllRequests() throws SQLException {
        List<BorrowRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY br.requested_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public int countPending() throws SQLException {
        String sql = "SELECT COUNT(*) FROM borrow_requests WHERE status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public boolean hasActiveBorrow(int bookId, int studentId) throws SQLException {
        String sql = "SELECT id FROM book_issues WHERE book_id=? AND student_id=? AND status IN ('issued','overdue')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            return ps.executeQuery().next();
        }
    }

    public boolean hasPendingRequest(int bookId, int studentId) throws SQLException {
        String sql = "SELECT id FROM borrow_requests WHERE book_id=? AND student_id=? AND status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            return ps.executeQuery().next();
        }
    }

    // Count how many books student currently has borrowed + pending requests
    public int countActiveBorrowsAndPending(int studentId) throws SQLException {
        String sql = "SELECT " +
            "(SELECT COUNT(*) FROM book_issues WHERE student_id=? AND status IN ('issued','overdue')) + " +
            "(SELECT COUNT(*) FROM borrow_requests WHERE student_id=? AND status='pending') AS total";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("total");
        }
        return 0;
    }

    private BorrowRequest map(ResultSet rs) throws SQLException {
        BorrowRequest r = new BorrowRequest();
        r.setId(rs.getInt("id"));
        r.setBookId(rs.getInt("book_id"));
        r.setBookTitle(rs.getString("book_title"));
        r.setBookIsbn(rs.getString("book_isbn"));
        r.setStudentId(rs.getInt("student_id"));
        r.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
        r.setStudentIdCode(rs.getString("student_id_code"));
        r.setStudentEmail(rs.getString("student_email"));
        r.setRequestedAt(rs.getTimestamp("requested_at"));
        r.setPreferredReturnDate(rs.getDate("preferred_return_date"));
        r.setStatus(rs.getString("status"));
        r.setNotes(rs.getString("notes"));
        r.setReviewedBy(rs.getInt("reviewed_by"));
        r.setReviewedAt(rs.getTimestamp("reviewed_at"));
        return r;
    }
}
