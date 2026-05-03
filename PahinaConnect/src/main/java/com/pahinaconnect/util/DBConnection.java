package com.pahinaconnect.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Read from environment variables (Railway) or fall back to local defaults
    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        // Railway provides MYSQL_URL, MYSQL_USER, MYSQL_PASSWORD
        // Local development uses hardcoded defaults
        String mysqlUrl  = System.getenv("MYSQL_URL");
        String mysqlUser = System.getenv("MYSQL_USER");
        String mysqlPass = System.getenv("MYSQL_PASSWORD");

        if (mysqlUrl != null && !mysqlUrl.isEmpty()) {
            // Railway environment
            URL      = mysqlUrl;
            USER     = mysqlUser != null ? mysqlUser : "root";
            PASSWORD = mysqlPass != null ? mysqlPass : "";
        } else {
            // Local development
            URL      = "jdbc:mysql://127.0.0.1:3306/pahina_connect?useSSL=false&serverTimezone=Asia/Manila&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
            USER     = "root";
            PASSWORD = "root";
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
