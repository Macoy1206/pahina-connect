-- ============================================================
-- Pahina Connect - Library Management System
-- Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS pahina_connect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pahina_connect;

-- ============================================================
-- USERS TABLE (Admin + Students)
-- ============================================================
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
    gender ENUM('Male','Female','Other'),
    profile_picture VARCHAR(255),
    role ENUM('admin','student') DEFAULT 'student',
    password VARCHAR(255) NOT NULL,
    otp VARCHAR(10),
    otp_expiry DATETIME,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- CATEGORIES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- AUTHORS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    nationality VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- BOOKS TABLE
-- ============================================================
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
    language VARCHAR(50) DEFAULT 'English',
    pages INT,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- ============================================================
-- BOOK ISSUES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS book_issues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME NOT NULL,
    return_date DATETIME,
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    fine_paid TINYINT(1) DEFAULT 0,
    status ENUM('issued','returned','overdue','lost') DEFAULT 'issued',
    issued_by INT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (issued_by) REFERENCES users(id)
);

-- ============================================================
-- RESERVATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    reserved_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    status ENUM('pending','fulfilled','cancelled','expired') DEFAULT 'pending',
    queue_position INT,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (student_id) REFERENCES users(id)
);

-- ============================================================
-- BORROW REQUESTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS borrow_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    preferred_return_date DATE,
    status ENUM('pending','approved','rejected','cancelled') DEFAULT 'pending',
    notes TEXT,
    reviewed_by INT,
    reviewed_at DATETIME,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (reviewed_by) REFERENCES users(id)
);

-- ============================================================
-- FINE SETTINGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS fine_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fine_per_day DECIMAL(10,2) DEFAULT 5.00,
    max_fine DECIMAL(10,2) DEFAULT 500.00,
    grace_period_days INT DEFAULT 0,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- EMAIL LOGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS email_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipient_email VARCHAR(150),
    subject VARCHAR(255),
    body TEXT,
    status ENUM('sent','failed') DEFAULT 'sent',
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- READING HISTORY / ANALYTICS
-- ============================================================
CREATE TABLE IF NOT EXISTS reading_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    book_id INT NOT NULL,
    borrowed_at DATETIME,
    returned_at DATETIME,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Default fine setting
INSERT INTO fine_settings (fine_per_day, max_fine, grace_period_days) VALUES (5.00, 500.00, 0);

-- Default admin account (password: Admin@123)
INSERT INTO users (student_id, first_name, last_name, email, phone, role, password, is_active)
VALUES (
    'ADMIN001',
    'System',
    'Administrator',
    'admin@pahinaconnect.com',
    '09000000000',
    'admin',
    '$2a$10$v4c1rcKKO/sWN0cmzuZa1eRNyr4FbJ9UCvx3tm2UZEarLebi31bBO',
    1
);

-- Sample categories
INSERT INTO categories (name, description) VALUES
('Fiction', 'Fictional literature and novels'),
('Non-Fiction', 'Factual books and biographies'),
('Science', 'Science and technology books'),
('History', 'Historical books and references'),
('Mathematics', 'Mathematics and statistics'),
('Computer Science', 'Programming and IT books'),
('Philosophy', 'Philosophy and ethics'),
('Arts', 'Arts, music, and culture'),
('Reference', 'Encyclopedias and dictionaries'),
('Children', 'Books for young readers');

-- Authors for the 20 ebook collection
-- IDs 1-5: Jose Rizal, Francisco Balagtas, Sun Tzu, William Shakespeare, Jane Austen
-- IDs 6-17: Homer, Aesop, Miguel de Cervantes, Charles Dickens, Victor Hugo,
--           Alexandre Dumas, Mark Twain, Robert Louis Stevenson, Rudyard Kipling,
--           Jules Verne, Severino Reyes, Plato
INSERT INTO authors (first_name, last_name, bio, nationality) VALUES
('Jose', 'Rizal', 'National hero and novelist of the Philippines', 'Filipino'),
('Francisco', 'Balagtas', 'Filipino poet, author of Florante at Laura', 'Filipino'),
('Sun', 'Tzu', 'Ancient Chinese military strategist and philosopher', 'Chinese'),
('William', 'Shakespeare', 'English playwright and poet of the Elizabethan era', 'British'),
('Jane', 'Austen', 'English novelist known for wit and social commentary', 'British'),
('Homer', '', 'Ancient Greek epic poet, author of the Iliad and Odyssey', 'Greek'),
('Aesop', '', 'Ancient Greek fabulist credited with a collection of moral tales', 'Greek'),
('Miguel de', 'Cervantes', 'Spanish novelist, author of Don Quixote', 'Spanish'),
('Charles', 'Dickens', 'Victorian English novelist and social critic', 'British'),
('Victor', 'Hugo', 'French poet, novelist, and dramatist', 'French'),
('Alexandre', 'Dumas', 'French author known for adventure novels', 'French'),
('Mark', 'Twain', 'American author and humorist', 'American'),
('Robert Louis', 'Stevenson', 'Scottish novelist and travel writer', 'British'),
('Rudyard', 'Kipling', 'British author and Nobel laureate', 'British'),
('Jules', 'Verne', 'French novelist, pioneer of science fiction', 'French'),
('Severino', 'Reyes', 'Filipino playwright and author known as Lola Basyang', 'Filipino'),
('Plato', '', 'Ancient Greek philosopher, student of Socrates', 'Greek');

-- 20 books, each with an ebook HTML file
-- author_id mapping: 1=Rizal, 2=Balagtas, 3=Sun Tzu, 4=Shakespeare, 5=Austen,
--   6=Homer, 7=Aesop, 8=Cervantes, 9=Dickens, 10=Hugo, 11=Dumas, 12=Twain,
--   13=Stevenson, 14=Kipling, 15=Verne, 16=Severino Reyes, 17=Plato
-- category_id: 1=Fiction, 7=Philosophy, 10=Children, 3=Science
INSERT INTO books (isbn, title, author_id, category_id, publisher, publication_year, edition, total_copies, available_copies, description, ebook_file, location, language, pages, cover_image) VALUES
('978-971-001', 'Noli Me Tangere', 1, 1, 'National Bookstore', 1887, '1st', 5, 5, 'Ang nobelang nagbunyag ng kabulukan ng lipunang Pilipino sa ilalim ng pananakop ng Espanya.', 'ebook_1.html', 'Shelf A-1', 'Filipino', 320, 'https://books.google.com/books/content?id=QnVnAAAAMAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api'),
('978-971-002', 'El Filibusterismo', 1, 1, 'National Bookstore', 1891, '1st', 5, 5, 'Ang pangalawang nobela ni Rizal na nagpapakita ng rebolusyonaryong landas.', 'ebook_2.html', 'Shelf A-1', 'Filipino', 280, 'https://books.google.com/books/content?id=5HhnAAAAMAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api'),
('978-971-003', 'Florante at Laura', 2, 1, 'Rex Bookstore', 1838, '5th', 4, 4, 'Isang awit-tanaga ni Francisco Balagtas tungkol sa pag-ibig, karangalan, at katarungan.', 'ebook_3.html', 'Shelf A-2', 'Filipino', 180, 'https://books.google.com/books/content?id=BQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-971-004', 'Ibong Adarna', 2, 1, 'Vibal Publishing', 1800, '3rd', 5, 5, 'Ang kwento ng mahiwagang ibong may kapangyarihang magpagaling at magpatulog.', 'ebook_4.html', 'Shelf A-3', 'Filipino', 200, 'https://books.google.com/books/content?id=xwZHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-005', 'The Art of War', 3, 7, 'Oxford University Press', 500, '5th', 5, 5, 'The ancient Chinese military treatise on strategy and philosophy by Sun Tzu.', 'ebook_5.html', 'Shelf G-1', 'English', 273, 'https://books.google.com/books/content?id=hXVJAAAAMAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-006', 'Romeo and Juliet', 4, 1, 'Oxford University Press', 1597, '3rd', 4, 4, 'The timeless tragedy of two young lovers from feuding families in Verona.', 'ebook_6.html', 'Shelf B-1', 'English', 180, 'https://books.google.com/books/content?id=wQ8OAAAAQAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-007', 'Hamlet', 4, 1, 'Oxford University Press', 1603, '2nd', 4, 4, 'The Prince of Denmark seeks revenge for his father''s murder in this classic tragedy.', 'ebook_7.html', 'Shelf B-2', 'English', 342, 'https://books.google.com/books/content?id=_Q8OAAAAQAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-008', 'Pride and Prejudice', 5, 1, 'T. Egerton', 1813, '2nd', 4, 4, 'A witty exploration of love, marriage, and social class in Regency-era England.', 'ebook_8.html', 'Shelf B-3', 'English', 432, 'https://books.google.com/books/content?id=s1gVAAAAYAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-009', 'The Odyssey', 6, 1, 'Penguin Classics', 800, '4th', 3, 3, 'The epic journey of Odysseus as he tries to return home after the Trojan War.', 'ebook_9.html', 'Shelf C-1', 'English', 541, 'https://books.google.com/books/content?id=MB8bAAAAYAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-010', 'Aesop''s Fables', 7, 10, 'Penguin Classics', 600, '6th', 6, 6, 'A collection of timeless moral tales featuring animals with human qualities.', 'ebook_10.html', 'Shelf H-1', 'English', 320, 'https://books.google.com/books/content?id=ygcJAAAAQAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-011', 'Don Quixote', 8, 1, 'Penguin Classics', 1605, '3rd', 3, 3, 'The adventures of an idealistic knight and his loyal squire Sancho Panza.', 'ebook_11.html', 'Shelf C-2', 'English', 863, 'https://books.google.com/books/content?id=VT0JAAAAQAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-012', 'A Tale of Two Cities', 9, 1, 'Chapman and Hall', 1859, '2nd', 4, 4, 'A story of love and sacrifice set during the French Revolution.', 'ebook_12.html', 'Shelf C-3', 'English', 489, 'https://books.google.com/books/content?id=PQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-013', 'Les Miserables', 10, 1, 'A. Lacroix', 1862, '2nd', 3, 3, 'The story of ex-convict Jean Valjean and his pursuit of redemption in 19th-century France.', 'ebook_13.html', 'Shelf C-4', 'English', 1463, 'https://books.google.com/books/content?id=YQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-014', 'The Count of Monte Cristo', 11, 1, 'Penguin Classics', 1844, '3rd', 3, 3, 'A tale of betrayal, imprisonment, and elaborate revenge by Alexandre Dumas.', 'ebook_14.html', 'Shelf C-5', 'English', 1276, 'https://books.google.com/books/content?id=ZQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-015', 'The Adventures of Tom Sawyer', 12, 1, 'American Publishing', 1876, '2nd', 5, 5, 'The mischievous adventures of a young boy growing up along the Mississippi River.', 'ebook_15.html', 'Shelf D-1', 'English', 274, 'https://books.google.com/books/content?id=AQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-016', 'Treasure Island', 13, 1, 'Cassell and Company', 1883, '3rd', 5, 5, 'A young boy''s adventure with pirates and the search for buried treasure.', 'ebook_16.html', 'Shelf D-2', 'English', 292, 'https://books.google.com/books/content?id=CQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-017', 'The Jungle Book', 14, 1, 'Macmillan', 1894, '4th', 5, 5, 'The story of Mowgli, a boy raised by wolves in the jungles of India.', 'ebook_17.html', 'Shelf D-3', 'English', 212, 'https://books.google.com/books/content?id=DQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-018', 'Twenty Thousand Leagues Under the Sea', 15, 3, 'Pierre-Jules Hetzel', 1870, '3rd', 3, 3, 'An underwater adventure aboard the mysterious submarine Nautilus.', 'ebook_18.html', 'Shelf E-1', 'English', 398, 'https://books.google.com/books/content?id=EQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-971-019', 'Mga Kwento ni Lola Basyang', 16, 10, 'Adarna House', 1925, '6th', 8, 8, 'Mga klasikong kwentong Pilipino na puno ng aral at kultura ng ating bansa.', 'ebook_19.html', 'Shelf H-2', 'Filipino', 320, 'https://books.google.com/books/content?id=7QNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api'),
('978-000-020', 'The Republic', 17, 7, 'Penguin Classics', 380, '5th', 3, 3, 'Plato''s philosophical dialogue on justice, the ideal state, and the nature of the soul.', 'ebook_20.html', 'Shelf G-2', 'English', 416, 'https://books.google.com/books/content?id=FQNHAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api');
