-- Railway Init SQL - runs when app starts
USE railway;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    gender ENUM("Male","Female","Other"),
    profile_picture VARCHAR(255),
    role ENUM("admin","student") DEFAULT "student",
    password VARCHAR(255) NOT NULL,
    otp VARCHAR(10),
    otp_expiry DATETIME,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    nationality VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    category_id INT,
    publisher VARCHAR(150),
    publication_year SMALLINT UNSIGNED,
    edition VARCHAR(50),
    total_copies INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    description TEXT,
    cover_image VARCHAR(255),
    ebook_file VARCHAR(255),
    qr_code VARCHAR(255),
    barcode VARCHAR(255),
    location VARCHAR(100),
    language VARCHAR(50) DEFAULT "English",
    pages INT,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS book_issues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME NOT NULL,
    return_date DATETIME,
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    fine_paid TINYINT(1) DEFAULT 0,
    status ENUM("issued","returned","overdue","lost") DEFAULT "issued",
    issued_by INT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (issued_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    reserved_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    status ENUM("pending","fulfilled","cancelled","expired") DEFAULT "pending",
    queue_position INT,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (student_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS borrow_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    preferred_return_date DATE,
    status ENUM("pending","approved","rejected","cancelled") DEFAULT "pending",
    notes TEXT,
    reviewed_by INT,
    reviewed_at DATETIME,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (reviewed_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS fine_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fine_per_day DECIMAL(10,2) DEFAULT 5.00,
    max_fine DECIMAL(10,2) DEFAULT 500.00,
    grace_period_days INT DEFAULT 0,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reading_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    book_id INT NOT NULL,
    borrowed_at DATETIME,
    returned_at DATETIME,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE TABLE IF NOT EXISTS fine_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    issue_id INT NOT NULL,
    student_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM("Cash","GCash","Maya","Bank Transfer","Other") NOT NULL,
    reference_number VARCHAR(50) NOT NULL,
    paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (issue_id) REFERENCES book_issues(id),
    FOREIGN KEY (student_id) REFERENCES users(id)
);

-- Insert default data only if not exists
INSERT IGNORE INTO fine_settings (fine_per_day, max_fine, grace_period_days) VALUES (5.00, 500.00, 0);

INSERT IGNORE INTO users (student_id, first_name, last_name, email, phone, role, password, is_active)
VALUES ("ADMIN001", "System", "Administrator", "admin@pahinaconnect.com", "09000000000", "admin",
"$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO", 1);