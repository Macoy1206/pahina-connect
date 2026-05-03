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
        String sql = "SELECT * FROM authors ORDER BY last_name, first_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapAuthor(rs));
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
