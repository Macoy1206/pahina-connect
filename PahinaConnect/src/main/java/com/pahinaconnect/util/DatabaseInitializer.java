package com.pahinaconnect.util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Automatically creates database tables on first startup.
 * This ensures Railway deployment works without manual SQL setup.
 */
public class DatabaseInitializer {

    public static void initialize() {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {

            // Users table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS users (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "student_id VARCHAR(20) UNIQUE," +
                "first_name VARCHAR(100) NOT NULL," +
                "last_name VARCHAR(100) NOT NULL," +
                "middle_name VARCHAR(100)," +
                "email VARCHAR(150) UNIQUE NOT NULL," +
                "phone VARCHAR(20)," +
                "address TEXT," +
                "date_of_birth DATE," +
                "gender ENUM('Male','Female','Other')," +
                "profile_picture VARCHAR(255)," +
                "role ENUM('admin','student') DEFAULT 'student'," +
                "password VARCHAR(255) NOT NULL," +
                "otp VARCHAR(10)," +
                "otp_expiry DATETIME," +
                "is_active TINYINT(1) DEFAULT 1," +
                "created_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );

            // Categories table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS categories (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "name VARCHAR(100) NOT NULL UNIQUE," +
                "description TEXT," +
                "created_at DATETIME DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Authors table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS authors (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "first_name VARCHAR(100) NOT NULL," +
                "last_name VARCHAR(100) NOT NULL," +
                "bio TEXT," +
                "nationality VARCHAR(100)," +
                "created_at DATETIME DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Books table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS books (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "isbn VARCHAR(20) UNIQUE NOT NULL," +
                "title VARCHAR(255) NOT NULL," +
                "author_id INT," +
                "category_id INT," +
                "publisher VARCHAR(150)," +
                "publication_year SMALLINT UNSIGNED," +
                "edition VARCHAR(50)," +
                "total_copies INT DEFAULT 1," +
                "available_copies INT DEFAULT 1," +
                "description TEXT," +
                "cover_image VARCHAR(255)," +
                "ebook_file VARCHAR(255)," +
                "qr_code VARCHAR(255)," +
                "barcode VARCHAR(255)," +
                "location VARCHAR(100)," +
                "language VARCHAR(50) DEFAULT 'English'," +
                "pages INT," +
                "is_active TINYINT(1) DEFAULT 1," +
                "created_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );

            // Book issues table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS book_issues (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "book_id INT NOT NULL," +
                "student_id INT NOT NULL," +
                "issue_date DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "due_date DATETIME NOT NULL," +
                "return_date DATETIME," +
                "fine_amount DECIMAL(10,2) DEFAULT 0.00," +
                "fine_paid TINYINT(1) DEFAULT 0," +
                "status ENUM('issued','returned','overdue','lost') DEFAULT 'issued'," +
                "issued_by INT," +
                "notes TEXT," +
                "created_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );

            // Reservations table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS reservations (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "book_id INT NOT NULL," +
                "student_id INT NOT NULL," +
                "reserved_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "expires_at DATETIME," +
                "status ENUM('pending','fulfilled','cancelled','expired') DEFAULT 'pending'," +
                "queue_position INT" +
                ")"
            );

            // Borrow requests table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS borrow_requests (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "book_id INT NOT NULL," +
                "student_id INT NOT NULL," +
                "requested_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "preferred_return_date DATE," +
                "status ENUM('pending','approved','rejected','cancelled') DEFAULT 'pending'," +
                "notes TEXT," +
                "reviewed_by INT," +
                "reviewed_at DATETIME" +
                ")"
            );

            // Fine settings table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS fine_settings (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "fine_per_day DECIMAL(10,2) DEFAULT 5.00," +
                "max_fine DECIMAL(10,2) DEFAULT 500.00," +
                "grace_period_days INT DEFAULT 0," +
                "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );

            // Reading history table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS reading_history (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "student_id INT NOT NULL," +
                "book_id INT NOT NULL," +
                "borrowed_at DATETIME," +
                "returned_at DATETIME" +
                ")"
            );

            // Fine payments table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS fine_payments (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "issue_id INT NOT NULL," +
                "student_id INT NOT NULL," +
                "amount DECIMAL(10,2) NOT NULL," +
                "payment_method ENUM('Cash','GCash','Maya','Bank Transfer','Other') NOT NULL," +
                "reference_number VARCHAR(50) NOT NULL," +
                "paid_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "notes TEXT" +
                ")"
            );

            // Email logs table
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS email_logs (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "recipient_email VARCHAR(150)," +
                "subject VARCHAR(255)," +
                "body TEXT," +
                "status ENUM('sent','failed') DEFAULT 'sent'," +
                "sent_at DATETIME DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Insert default fine settings if not exists
            st.executeUpdate(
                "INSERT IGNORE INTO fine_settings (id, fine_per_day, max_fine, grace_period_days) " +
                "VALUES (1, 5.00, 500.00, 0)"
            );

            // Insert default admin account if not exists (password: Admin@123)
            st.executeUpdate(
                "INSERT IGNORE INTO users (student_id, first_name, last_name, email, phone, role, password, is_active) " +
                "VALUES ('ADMIN001', 'System', 'Administrator', 'admin@pahinaconnect.com', '09000000000', 'admin', " +
                "'$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO', 1)"
            );

            // Insert existing student accounts (password: Student@123 for sample accounts)
            st.executeUpdate(
                "INSERT IGNORE INTO users (student_id, first_name, last_name, middle_name, email, phone, address, date_of_birth, gender, role, password, is_active) VALUES " +
                "('STU0001234','Juan','Dela Cruz','Santos','juan.delacruz@student.com','09171234567','123 Rizal St., Manila','2000-01-15','Male','student','$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO',1)," +
                "('STU0001235','Maria','Santos','Garcia','maria.santos@student.com','09181234567','456 Bonifacio Ave., Quezon City','2001-03-20','Female','student','$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO',1)," +
                "('STU0001236','Pedro','Reyes','Lopez','pedro.reyes@student.com','09191234567','789 Mabini St., Makati','1999-07-10','Male','student','$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO',1)," +
                "('STU0001237','Ana','Gonzales','Ramos','ana.gonzales@student.com','09201234567','321 Luna St., Pasig','2002-05-25','Female','student','$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO',1)," +
                "('STU0001238','Jose','Mendoza','Cruz','jose.mendoza@student.com','09211234567','654 Aguinaldo Rd., Taguig','2000-11-30','Male','student','$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO',1)," +
                "('STU5757207','Ronald','Cabalde',NULL,'macoycabalde@gmail.com','09615150075','Purok 3 Barangay Pansol Pila, Laguna','2000-01-01','Male','student','$2a$10$FsNGD/49JaHe3WGxDwL5Ru7ydTWCIvNiy93SGcEkGCWviI.wZE7Gu',1)"
            );

            System.out.println("[DatabaseInitializer] Database initialized successfully.");

        } catch (SQLException e) {
            System.err.println("[DatabaseInitializer] Error: " + e.getMessage());
        }
    }
}
