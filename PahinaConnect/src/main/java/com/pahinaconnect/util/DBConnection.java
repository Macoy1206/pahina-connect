package com.pahinaconnect.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        String tempUrl, tempUser, tempPass;

        // Priority 1: MYSQL_URL (jdbc format)
        String mysqlUrl = System.getenv("MYSQL_URL");

        // Priority 2: MYSQL_PUBLIC_URL (mysql:// format)
        if (mysqlUrl == null || mysqlUrl.isEmpty()) {
            mysqlUrl = System.getenv("MYSQL_PUBLIC_URL");
        }

        // Priority 3: Individual Railway MySQL variables (MYSQLHOST, MYSQLPORT, etc.)
        String railwayHost = System.getenv("MYSQLHOST");
        String railwayPort = System.getenv("MYSQLPORT");
        String railwayDb   = System.getenv("MYSQLDATABASE");
        String railwayUser = System.getenv("MYSQLUSER");
        String railwayPass = System.getenv("MYSQLPASSWORD");

        String mysqlUser = System.getenv("MYSQL_USER");
        String mysqlPass = System.getenv("MYSQL_PASSWORD");

        if (mysqlUrl != null && !mysqlUrl.isEmpty()) {
            if (mysqlUrl.startsWith("mysql://")) {
                // Convert mysql://user:pass@host:port/db to jdbc format
                try {
                    String s = mysqlUrl.substring("mysql://".length());
                    String ui = s.substring(0, s.indexOf('@'));
                    String hd = s.substring(s.indexOf('@') + 1);
                    tempUser = ui.contains(":") ? ui.substring(0, ui.indexOf(':')) : ui;
                    tempPass = ui.contains(":") ? ui.substring(ui.indexOf(':') + 1) : "";
                    tempUrl  = "jdbc:mysql://" + hd + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
                } catch (Exception e) {
                    tempUrl  = "jdbc:mysql://" + mysqlUrl.replace("mysql://", "") + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
                    tempUser = mysqlUser != null ? mysqlUser : "root";
                    tempPass = mysqlPass != null ? mysqlPass : "";
                }
            } else {
                // Already jdbc format
                tempUrl  = mysqlUrl;
                tempUser = mysqlUser != null ? mysqlUser : "root";
                tempPass = mysqlPass != null ? mysqlPass : "";
            }
        } else if (railwayHost != null && !railwayHost.isEmpty()) {
            // Use individual Railway variables
            String port = (railwayPort != null && !railwayPort.isEmpty()) ? railwayPort : "3306";
            String db   = (railwayDb   != null && !railwayDb.isEmpty())   ? railwayDb   : "railway";
            tempUrl  = "jdbc:mysql://" + railwayHost + ":" + port + "/" + db +
                       "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
            tempUser = railwayUser != null ? railwayUser : "root";
            tempPass = railwayPass != null ? railwayPass : "";
        } else {
            // Local development
            tempUrl  = "jdbc:mysql://127.0.0.1:3306/pahina_connect?useSSL=false&serverTimezone=Asia/Manila&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
            tempUser = "root";
            tempPass = "root";
        }

        URL      = tempUrl;
        USER     = tempUser;
        PASSWORD = tempPass;

        System.out.println("[DBConnection] URL: " + URL);
        System.out.println("[DBConnection] USER: " + USER);

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
