package com.pahinaconnect.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.pahinaconnect.model.BookIssue;
import com.pahinaconnect.util.DBConnection;

public class BookIssueDAO {

    public int issueBook(BookIssue issue, Connection conn) throws SQLException {
        String sql = "INSERT INTO book_issues (book_id, student_id, due_date, issued_by, notes) VALUES (?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, issue.getBookId());
            ps.setInt(2, issue.getStudentId());
            ps.setTimestamp(3, issue.getDueDate());
            ps.setInt(4, issue.getIssuedBy());
            ps.setString(5, issue.getNotes());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        }
        return -1;
    }

    public boolean returnBook(int issueId, double fineAmount, boolean finePaid) throws SQLException {
        String sql = "UPDATE book_issues SET return_date=NOW(), fine_amount=?, fine_paid=?, status='returned' WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, fineAmount);
            ps.setBoolean(2, finePaid);
            ps.setInt(3, issueId);
            return ps.executeUpdate() > 0;
        }
    }

    public BookIssue findById(int id) throws SQLException {
        return getIssueById(id);
    }

    public BookIssue getIssueById(int id) throws SQLException {
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code, u.email AS student_email " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                BookIssue i = mapIssue(rs);
                i.setStudentEmail(rs.getString("student_email"));
                return i;
            }
        }
        return null;
    }

    public List<BookIssue> getActiveIssuesByStudent(int studentId) throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.student_id=? AND bi.status IN ('issued','overdue') ORDER BY bi.due_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapIssue(rs));
        }
        return list;
    }

    public List<BookIssue> getAllIssuesByStudent(int studentId) throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.student_id=? ORDER BY bi.issue_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapIssue(rs));
        }
        return list;
    }

    public List<BookIssue> getAllActiveIssues() throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.status IN ('issued','overdue') ORDER BY bi.due_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapIssue(rs));
        }
        return list;
    }

    public List<BookIssue> getAllIssues() throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "ORDER BY bi.issue_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapIssue(rs));
        }
        return list;
    }

    public List<BookIssue> getOverdueIssues() throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.status IN ('issued','overdue') AND bi.due_date < NOW() ORDER BY bi.due_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapIssue(rs));
        }
        return list;
    }

    public void updateOverdueStatuses() throws SQLException {
        String sql = "UPDATE book_issues SET status='overdue' WHERE status='issued' AND due_date < NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    public int countActiveIssues() throws SQLException {
        String sql = "SELECT COUNT(*) FROM book_issues WHERE status IN ('issued','overdue')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countOverdueIssues() throws SQLException {
        String sql = "SELECT COUNT(*) FROM book_issues WHERE status IN ('issued','overdue') AND due_date < NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public double getTotalFines() throws SQLException {
        String sql = "SELECT COALESCE(SUM(fine_amount),0) FROM book_issues WHERE fine_paid=0 AND fine_amount > 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        }
        return 0;
    }

    // Get issues due in next N days for reminders
    public List<BookIssue> getIssuesDueSoon(int days) throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code, u.email AS student_email " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.status='issued' AND bi.due_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL ? DAY)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BookIssue i = mapIssue(rs);
                i.setStudentEmail(rs.getString("student_email"));
                list.add(i);
            }
        }
        return list;
    }

    // Get all overdue issues with student email for reminders
    public List<BookIssue> getOverdueIssuesWithEmail() throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code, u.email AS student_email " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.status IN ('issued','overdue') AND bi.due_date < NOW() ORDER BY bi.due_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BookIssue i = mapIssue(rs);
                i.setStudentEmail(rs.getString("student_email"));
                list.add(i);
            }
        }
        return list;
    }

    // Get ALL active issues (regardless of due date) — for force/test reminders
    public List<BookIssue> getAllActiveIssuesWithEmail() throws SQLException {
        List<BookIssue> list = new ArrayList<>();
        String sql = "SELECT bi.*, b.title AS book_title, b.isbn AS book_isbn, " +
                     "u.first_name, u.last_name, u.student_id AS student_id_code, u.email AS student_email " +
                     "FROM book_issues bi " +
                     "JOIN books b ON bi.book_id=b.id " +
                     "JOIN users u ON bi.student_id=u.id " +
                     "WHERE bi.status IN ('issued','overdue') ORDER BY bi.due_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BookIssue i = mapIssue(rs);
                i.setStudentEmail(rs.getString("student_email"));
                list.add(i);
            }
        }
        return list;
    }

    private BookIssue mapIssue(ResultSet rs) throws SQLException {
        BookIssue i = new BookIssue();
        i.setId(rs.getInt("id"));
        i.setBookId(rs.getInt("book_id"));
        i.setBookTitle(rs.getString("book_title"));
        i.setBookIsbn(rs.getString("book_isbn"));
        i.setStudentId(rs.getInt("student_id"));
        i.setStudentName(rs.getString("first_name") + " " + rs.getString("last_name"));
        i.setStudentIdCode(rs.getString("student_id_code"));
        i.setIssueDate(rs.getTimestamp("issue_date"));
        i.setDueDate(rs.getTimestamp("due_date"));
        i.setReturnDate(rs.getTimestamp("return_date"));
        i.setFineAmount(rs.getDouble("fine_amount"));
        i.setFinePaid(rs.getBoolean("fine_paid"));
        i.setStatus(rs.getString("status"));
        i.setIssuedBy(rs.getInt("issued_by"));
        i.setNotes(rs.getString("notes"));
        return i;
    }
}
