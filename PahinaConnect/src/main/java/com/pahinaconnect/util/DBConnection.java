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
        String mysqlUrl  = System.getenv("MYSQL_URL");
        if (mysqlUrl == null || mysqlUrl.isEmpty()) {
            mysqlUrl = System.getenv("MYSQL_PUBLIC_URL");
        }
        String mysqlUser = System.getenv("MYSQL_USER");
        String mysqlPass = System.getenv("MYSQL_PASSWORD");

        String tempUrl, tempUser, tempPass;

        if (mysqlUrl != null && !mysqlUrl.isEmpty()) {
            if (mysqlUrl.startsWith("mysql://")) {
                try {
                    String withoutScheme = mysqlUrl.substring("mysql://".length());
                    String userInfo = withoutScheme.substring(0, withoutScheme.indexOf('@'));
                    String hostAndDb = withoutScheme.substring(withoutScheme.indexOf('@') + 1);
                    tempUser = userInfo.contains(":") ? userInfo.substring(0, userInfo.indexOf(':')) : userInfo;
                    tempPass = userInfo.contains(":") ? userInfo.substring(userInfo.indexOf(':') + 1) : "";
                    tempUrl  = "jdbc:mysql://" + hostAndDb + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
                } catch (Exception e) {
                    tempUrl  = "jdbc:mysql://" + mysqlUrl.replace("mysql://", "") + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
                    tempUser = mysqlUser != null ? mysqlUser : "root";
                    tempPass = mysqlPass != null ? mysqlPass : "";
                }
            } else {
                tempUrl  = mysqlUrl;
                tempUser = mysqlUser != null ? mysqlUser : "root";
                tempPass = mysqlPass != null ? mysqlPass : "";
            }
        } else {
            tempUrl  = "jdbc:mysql://127.0.0.1:3306/pahina_connect?useSSL=false&serverTimezone=Asia/Manila&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
            tempUser = "root";
            tempPass = "root";
        }

        URL      = tempUrl;
        USER     = tempUser;
        PASSWORD = tempPass;

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
