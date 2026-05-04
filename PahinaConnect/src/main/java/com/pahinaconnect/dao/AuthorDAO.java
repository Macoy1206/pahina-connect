package com.pahinaconnect.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.pahinaconnect.model.Author;
import com.pahinaconnect.util.DBConnection;

public class AuthorDAO {

    public List<Author> getAll() throws SQLException {
        List<Author> list = new ArrayList<>();
        // Order alphabetically by last name then first name, no duplicates
        String sql = "SELECT * FROM authors ORDER BY last_name, first_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            java.util.Set<String> seen = new java.util.HashSet<>();
            while (rs.next()) {
                String key = rs.getString("first_name").toLowerCase() + "|" + rs.getString("last_name").toLowerCase();
                if (seen.add(key)) { // only add if not seen before
                    list.add(mapAuthor(rs));
                }
            }
        }
        return list;
    }

    public Author findById(int id) throws SQLException {
        String sql = "SELECT * FROM authors WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapAuthor(rs);
        }
        return null;
    }

    public boolean add(Author author) throws SQLException {
        // Check for duplicate before inserting
        String checkSql = "SELECT id FROM authors WHERE LOWER(first_name)=LOWER(?) AND LOWER(last_name)=LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setString(1, author.getFirstName());
            check.setString(2, author.getLastName());
            ResultSet rs = check.executeQuery();
            if (rs.next()) return false; // Already exists
        }
        String sql = "INSERT INTO authors (first_name, last_name, bio, nationality) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, author.getFirstName());
            ps.setString(2, author.getLastName());
            ps.setString(3, author.getBio());
            ps.setString(4, author.getNationality());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean update(Author author) throws SQLException {
        String sql = "UPDATE authors SET first_name=?, last_name=?, bio=?, nationality=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, author.getFirstName());
            ps.setString(2, author.getLastName());
            ps.setString(3, author.getBio());
            ps.setString(4, author.getNationality());
            ps.setInt(5, author.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM authors WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Author mapAuthor(ResultSet rs) throws SQLException {
        Author a = new Author();
        a.setId(rs.getInt("id"));
        a.setFirstName(rs.getString("first_name"));
        a.setLastName(rs.getString("last_name"));
        a.setBio(rs.getString("bio"));
        a.setNationality(rs.getString("nationality"));
        return a;
    }
}
