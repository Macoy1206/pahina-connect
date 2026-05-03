package com.pahinaconnect.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.pahinaconnect.util.DBConnection;

public class ReservationDAO {

    public boolean reserve(int bookId, int studentId) throws SQLException {
        // Check if already reserved
        String checkSql = "SELECT id FROM reservations WHERE book_id=? AND student_id=? AND status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setInt(1, bookId);
            check.setInt(2, studentId);
            if (check.executeQuery().next()) return false; // already reserved
        }

        // Get queue position
        String posSql = "SELECT COALESCE(MAX(queue_position),0)+1 FROM reservations WHERE book_id=? AND status='pending'";
        int pos = 1;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(posSql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) pos = rs.getInt(1);
        }

        String sql = "INSERT INTO reservations (book_id, student_id, expires_at, queue_position) " +
                     "VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 7 DAY), ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            ps.setInt(3, pos);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean cancelReservation(int reservationId, int studentId) throws SQLException {
        String sql = "UPDATE reservations SET status='cancelled' WHERE id=? AND student_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Map<String, Object>> getReservationsByStudent(int studentId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT r.*, b.title, b.isbn FROM reservations r " +
                     "JOIN books b ON r.book_id=b.id WHERE r.student_id=? ORDER BY r.reserved_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("bookTitle", rs.getString("title"));
                m.put("isbn", rs.getString("isbn"));
                m.put("status", rs.getString("status"));
                m.put("queuePosition", rs.getInt("queue_position"));
                m.put("reservedAt", rs.getTimestamp("reserved_at"));
                m.put("expiresAt", rs.getTimestamp("expires_at"));
                list.add(m);
            }
        }
        return list;
    }

    public int getQueueCount(int bookId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reservations WHERE book_id=? AND status='pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}
