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
                "suffix VARCHAR(20)," +
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

            // Add suffix column if it doesn't exist (for existing databases)
            try {
                st.executeUpdate("ALTER TABLE users ADD COLUMN suffix VARCHAR(20) AFTER middle_name");
            } catch (Exception ignored) {
                // Column already exists, ignore
            }

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

            // Insert categories
            st.executeUpdate(
                "INSERT IGNORE INTO categories (name, description) VALUES " +
                "('Fiction','Fictional literature and novels')," +
                "('Non-Fiction','Factual books and biographies')," +
                "('Science','Science and technology books')," +
                "('History','Historical books and references')," +
                "('Mathematics','Mathematics and statistics')," +
                "('Computer Science','Programming and IT books')," +
                "('Philosophy','Philosophy and ethics')," +
                "('Arts','Arts, music, and culture')," +
                "('Reference','Encyclopedias and dictionaries')," +
                "('Children','Books for young readers')," +
                "('Classic Literature','Timeless works of classic literature')," +
                "('Filipino Literature','Works by Filipino authors')," +
                "('Russian Literature','Classic works from Russian authors')," +
                "('American Literature','Classic and modern American literary works')," +
                "('Epic Poetry','Epic poems and long narrative poetry')," +
                "('Dystopian Fiction','Dystopian and speculative fiction')," +
                "('Adventure','Adventure and exploration stories')," +
                "('Social Criticism','Literature that critiques society and politics')"
            );

            // Insert authors
            st.executeUpdate(
                "INSERT IGNORE INTO authors (first_name, last_name, bio, nationality) VALUES " +
                "('Jose','Rizal','National hero and novelist of the Philippines','Filipino')," +
                "('Francisco','Balagtas','Filipino poet, author of Florante at Laura','Filipino')," +
                "('Nick','Joaquin','Filipino writer and journalist, National Artist','Filipino')," +
                "('F. Sionil','Jose','Filipino novelist and National Artist for Literature','Filipino')," +
                "('Lualhati','Bautista','Filipino novelist and screenwriter','Filipino')," +
                "('Jane','Austen','English novelist known for wit and social commentary','British')," +
                "('Charles','Dickens','Victorian English novelist and social critic','British')," +
                "('Mark','Twain','American author and humorist','American')," +
                "('Charlotte','Bronte','English novelist and poet','British')," +
                "('Emily','Bronte','English novelist and poet','British')," +
                "('Louisa May','Alcott','American novelist and poet','American')," +
                "('Lewis','Carroll','English writer and mathematician','British')," +
                "('Oscar','Wilde','Irish poet and playwright','Irish')," +
                "('Arthur Conan','Doyle','British writer, creator of Sherlock Holmes','British')," +
                "('Jules','Verne','French novelist, pioneer of science fiction','French')," +
                "('H.G.','Wells','English writer, father of science fiction','British')," +
                "('Bram','Stoker','Irish author, creator of Dracula','Irish')," +
                "('Mary','Shelley','English novelist, author of Frankenstein','British')," +
                "('Robert Louis','Stevenson','Scottish novelist and travel writer','British')," +
                "('Jack','London','American novelist and journalist','American')," +
                "('F. Scott','Fitzgerald','American novelist known for The Great Gatsby','American')," +
                "('Harper','Lee','American novelist, Pulitzer Prize winner','American')," +
                "('George','Orwell','English novelist known for 1984 and Animal Farm','British')," +
                "('Ernest','Hemingway','American novelist and Nobel laureate','American')," +
                "('John','Steinbeck','American author and Nobel laureate','American')," +
                "('J.D.','Salinger','American author known for The Catcher in the Rye','American')," +
                "('William','Golding','British novelist and Nobel laureate','British')," +
                "('Aldous','Huxley','English writer and philosopher','British')," +
                "('Nathaniel','Hawthorne','American novelist known for The Scarlet Letter','American')," +
                "('Herman','Melville','American novelist known for Moby Dick','American')," +
                "('Leo','Tolstoy','Russian novelist, author of War and Peace','Russian')," +
                "('Fyodor','Dostoevsky','Russian novelist, author of Crime and Punishment','Russian')," +
                "('Lope K.','Santos','Filipino novelist, author of Banaag at Sikat','Filipino')," +
                "('Amado V.','Hernandez','Filipino poet and novelist, National Artist','Filipino')," +
                "('Edgardo','Reyes','Filipino novelist, author of Sa Mga Kuko ng Liwanag','Filipino')," +
                "('Dante','Alighieri','Italian poet, author of The Divine Comedy','Italian')," +
                "('John','Milton','English poet known for Paradise Lost','British')," +
                "('Jonathan','Swift','Anglo-Irish satirist, author of Gullivers Travels','Irish')," +
                "('Daniel','Defoe','English novelist, author of Robinson Crusoe','British')," +
                "('Victor','Hugo','French poet, novelist, and dramatist','French')"
            );

            // Insert books 1-25
            st.executeUpdate(
                "INSERT IGNORE INTO books (isbn, title, author_id, category_id, publisher, publication_year, edition, total_copies, available_copies, description, ebook_file, location, language, pages, cover_image) VALUES " +
                "('9780143106395','Noli Me Tangere',1,12,'Penguin Classics',1887,'Penguin Edition',5,5,'Ang nobelang nagbunyag ng kabulukan ng lipunang Pilipino sa ilalim ng pananakop ng Espanya.','ebook_1.html','Shelf A-1','Filipino',320,'https://covers.openlibrary.org/b/isbn/9780143106395-L.jpg')," +
                "('9780143039693','El Filibusterismo',1,12,'Penguin Classics',1891,'Penguin Edition',5,5,'Ang pangalawang nobela ni Rizal na nagpapakita ng rebolusyonaryong landas.','ebook_2.html','Shelf A-2','Filipino',280,'https://covers.openlibrary.org/b/isbn/9780143039693-L.jpg')," +
                "('9789712719370','Florante at Laura',2,12,'Anvil Publishing',1838,'Modern Edition',4,4,'Isang awit-tanaga ni Francisco Balagtas tungkol sa pag-ibig at katarungan.','ebook_3.html','Shelf A-3','Filipino',180,'https://covers.openlibrary.org/b/isbn/9789712719370-L.jpg')," +
                "('9789710851041','The Woman Who Had Two Navels',3,12,'Penguin Random House',1961,'Modern Edition',3,3,'A masterpiece of Filipino literature by Nick Joaquin.','ebook_4.html','Shelf A-4','English',240,'https://covers.openlibrary.org/b/isbn/9789710851041-L.jpg')," +
                "('9789710851058','Po-on',4,12,'Solidaridad Publishing',1984,'1st Edition',3,3,'The first novel in F. Sionil Jose Rosales Saga.','ebook_5.html','Shelf A-5','English',320,'https://covers.openlibrary.org/b/isbn/9789710851058-L.jpg')," +
                "('9780141439518','Pride and Prejudice',6,11,'Penguin Classics',1813,'Penguin Edition',5,5,'A witty exploration of love, marriage, and social class in Regency-era England.','ebook_6.html','Shelf B-1','English',432,'https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg')," +
                "('9780141439600','A Tale of Two Cities',7,11,'Penguin Classics',1859,'Penguin Edition',4,4,'A story of love and sacrifice set during the French Revolution.','ebook_7.html','Shelf B-2','English',489,'https://covers.openlibrary.org/b/isbn/9780141439600-L.jpg')," +
                "('9780143039563','The Adventures of Tom Sawyer',8,14,'Penguin Classics',1876,'Penguin Edition',5,5,'The mischievous adventures of a young boy growing up along the Mississippi River.','ebook_8.html','Shelf B-3','English',274,'https://covers.openlibrary.org/b/isbn/9780143039563-L.jpg')," +
                "('9780141441146','Jane Eyre',9,11,'Penguin Classics',1847,'Penguin Edition',4,4,'The story of an orphaned girl who becomes a governess and falls in love with Mr. Rochester.','ebook_9.html','Shelf B-4','English',624,'https://covers.openlibrary.org/b/isbn/9780141441146-L.jpg')," +
                "('9780141439556','Wuthering Heights',10,11,'Penguin Classics',1847,'Penguin Edition',3,3,'A passionate tale of love and revenge on the Yorkshire moors.','ebook_10.html','Shelf B-5','English',416,'https://covers.openlibrary.org/b/isbn/9780141439556-L.jpg')," +
                "('9780147514011','Little Women',11,14,'Penguin Classics',1868,'Penguin Edition',5,5,'The beloved story of the four March sisters growing up during the Civil War.','ebook_11.html','Shelf C-1','English',544,'https://covers.openlibrary.org/b/isbn/9780147514011-L.jpg')," +
                "('9780141439761','Alice Adventures in Wonderland',12,10,'Penguin Classics',1865,'Penguin Edition',6,6,'Alice falls down a rabbit hole into a fantasy world of peculiar creatures.','ebook_12.html','Shelf C-2','English',192,'https://covers.openlibrary.org/b/isbn/9780141439761-L.jpg')," +
                "('9780141439594','The Picture of Dorian Gray',13,11,'Penguin Classics',1890,'Penguin Edition',4,4,'A young man sells his soul for eternal youth and beauty.','ebook_13.html','Shelf C-3','English',256,'https://covers.openlibrary.org/b/isbn/9780141439594-L.jpg')," +
                "('9780141034355','The Adventures of Sherlock Holmes',14,11,'Penguin Classics',1892,'Penguin Edition',5,5,'Twelve thrilling detective stories featuring Sherlock Holmes and Dr. Watson.','ebook_14.html','Shelf C-4','English',320,'https://covers.openlibrary.org/b/isbn/9780141034355-L.jpg')," +
                "('9780140449082','Twenty Thousand Leagues Under the Sea',15,3,'Penguin Classics',1870,'Penguin Edition',3,3,'An underwater adventure aboard the mysterious submarine Nautilus.','ebook_15.html','Shelf D-1','English',398,'https://covers.openlibrary.org/b/isbn/9780140449082-L.jpg')," +
                "('9780141439976','The Time Machine',16,3,'Penguin Classics',1895,'Penguin Edition',3,3,'A scientist travels to the year 802701 and discovers the fate of humanity.','ebook_16.html','Shelf D-2','English',118,'https://covers.openlibrary.org/b/isbn/9780141439976-L.jpg')," +
                "('9780141439846','Dracula',17,11,'Penguin Classics',1897,'Penguin Edition',4,4,'The classic vampire tale of Count Dracula and his attempt to move to England.','ebook_17.html','Shelf D-3','English',488,'https://covers.openlibrary.org/b/isbn/9780141439846-L.jpg')," +
                "('9780141439471','Frankenstein',18,3,'Penguin Classics',1818,'Penguin Edition',3,3,'The story of Victor Frankenstein and his creation of a monster.','ebook_18.html','Shelf D-4','English',280,'https://covers.openlibrary.org/b/isbn/9780141439471-L.jpg')," +
                "('9780141192451','Treasure Island',19,17,'Penguin Classics',1883,'Penguin Edition',5,5,'A young boy adventure with pirates and the search for buried treasure.','ebook_19.html','Shelf E-1','English',292,'https://covers.openlibrary.org/b/isbn/9780141192451-L.jpg')," +
                "('9780141321059','The Call of the Wild',20,17,'Penguin Classics',1903,'Penguin Edition',4,4,'The story of Buck, a dog sold as a sled dog in the Yukon during the Gold Rush.','ebook_20.html','Shelf E-2','English',232,'https://covers.openlibrary.org/b/isbn/9780141321059-L.jpg')," +
                "('9780743273565','The Great Gatsby',21,14,'Scribner',1925,'Scribner Edition',4,4,'The story of the mysterious millionaire Jay Gatsby and his obsession with Daisy Buchanan.','ebook_21.html','Shelf F-1','English',180,'https://covers.openlibrary.org/b/isbn/9780743273565-L.jpg')," +
                "('9780061935466','To Kill a Mockingbird',22,14,'HarperCollins',1960,'Perennial Edition',5,5,'Atticus Finch defends a Black man accused of a crime in the American South.','ebook_22.html','Shelf F-2','English',281,'https://covers.openlibrary.org/b/isbn/9780061935466-L.jpg')," +
                "('9780451524935','1984',23,16,'Signet Classic',1949,'Signet Edition',5,5,'A chilling dystopian novel about a totalitarian society where Big Brother watches every move.','ebook_23.html','Shelf F-3','English',328,'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg')," +
                "('9780451526342','Animal Farm',23,18,'Signet Classic',1945,'Signet Edition',5,5,'A satirical allegory of Soviet totalitarianism in which farm animals overthrow their farmer.','ebook_24.html','Shelf F-4','English',112,'https://covers.openlibrary.org/b/isbn/9780451526342-L.jpg')," +
                "('9780684801223','The Old Man and the Sea',24,14,'Scribner',1952,'Scribner Edition',4,4,'An aging Cuban fisherman struggles with a giant marlin in this Pulitzer Prize-winning novella.','ebook_25.html','Shelf F-5','English',127,'https://covers.openlibrary.org/b/isbn/9780684801223-L.jpg')"
            );

            // Insert books 26-50
            st.executeUpdate(
                "INSERT IGNORE INTO books (isbn, title, author_id, category_id, publisher, publication_year, edition, total_copies, available_copies, description, ebook_file, location, language, pages, cover_image) VALUES " +
                "('9780140177398','Of Mice and Men',25,14,'Penguin Books',1937,'Penguin Edition',4,4,'Two displaced migrant ranch workers search for work during the Great Depression.','ebook_26.html','Shelf F-6','English',112,'https://covers.openlibrary.org/b/isbn/9780140177398-L.jpg')," +
                "('9780316769174','The Catcher in the Rye',26,14,'Little Brown',1951,'Back Bay Edition',4,4,'Holden Caulfield wanders around New York City after being expelled from prep school.','ebook_27.html','Shelf G-1','English',277,'https://covers.openlibrary.org/b/isbn/9780316769174-L.jpg')," +
                "('9780399501487','Lord of the Flies',27,11,'Perigee Books',1954,'Perigee Edition',4,4,'British boys stranded on an island attempt to govern themselves with disastrous results.','ebook_28.html','Shelf G-2','English',224,'https://covers.openlibrary.org/b/isbn/9780399501487-L.jpg')," +
                "('9780060850524','Brave New World',28,16,'HarperCollins',1932,'Perennial Edition',4,4,'A futuristic society where humans are genetically engineered for rigid caste roles.','ebook_29.html','Shelf G-3','English',311,'https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg')," +
                "('9780142437261','The Scarlet Letter',29,14,'Penguin Classics',1850,'Penguin Edition',3,3,'Hester Prynne struggles to create a new life in 17th-century Puritan Boston.','ebook_30.html','Shelf G-4','English',238,'https://covers.openlibrary.org/b/isbn/9780142437261-L.jpg')," +
                "('9781503280786','Moby Dick',30,14,'CreateSpace',1851,'Modern Edition',3,3,'Captain Ahab obsessively seeks revenge on the white whale Moby Dick.','ebook_31.html','Shelf G-5','English',654,'https://covers.openlibrary.org/b/isbn/9781503280786-L.jpg')," +
                "('9780486280615','The Adventures of Huckleberry Finn',8,14,'Dover Publications',1884,'Dover Edition',5,5,'Huck Finn and Jim travel down the Mississippi River on a raft.','ebook_32.html','Shelf H-1','English',366,'https://covers.openlibrary.org/b/isbn/9780486280615-L.jpg')," +
                "('9780141439563','Great Expectations',7,11,'Penguin Classics',1861,'Penguin Edition',4,4,'Pip, an orphan, unexpectedly comes into a fortune and navigates Victorian society.','ebook_33.html','Shelf H-2','English',544,'https://covers.openlibrary.org/b/isbn/9780141439563-L.jpg')," +
                "('9780141439747','Oliver Twist',7,11,'Penguin Classics',1838,'Penguin Edition',4,4,'An orphan boy escapes from a workhouse and falls in with a gang of thieves in London.','ebook_34.html','Shelf H-3','English',480,'https://covers.openlibrary.org/b/isbn/9780141439747-L.jpg')," +
                "('9780141439648','David Copperfield',7,11,'Penguin Classics',1850,'Penguin Edition',3,3,'The semi-autobiographical story of David Copperfield from childhood to maturity.','ebook_35.html','Shelf H-4','English',882,'https://covers.openlibrary.org/b/isbn/9780141439648-L.jpg')," +
                "('9780143035008','Anna Karenina',31,13,'Penguin Classics',1878,'Penguin Edition',3,3,'The tragic story of Anna Karenina and her doomed love affair with Count Vronsky.','ebook_36.html','Shelf I-1','English',864,'https://covers.openlibrary.org/b/isbn/9780143035008-L.jpg')," +
                "('9781400079988','War and Peace',31,13,'Vintage Classics',1869,'Vintage Edition',2,2,'An epic novel chronicling the French invasion of Russia through five aristocratic families.','ebook_37.html','Shelf I-2','English',1296,'https://covers.openlibrary.org/b/isbn/9781400079988-L.jpg')," +
                "('9780140449136','Crime and Punishment',32,13,'Penguin Classics',1866,'Penguin Edition',4,4,'Student Raskolnikov commits a murder and struggles with guilt in this psychological masterpiece.','ebook_38.html','Shelf I-3','English',671,'https://covers.openlibrary.org/b/isbn/9780140449136-L.jpg')," +
                "('9780374528379','The Brothers Karamazov',32,13,'Farrar Straus',1880,'FSG Edition',3,3,'A philosophical novel about faith, doubt, and morality centered on a father murder.','ebook_39.html','Shelf I-4','English',796,'https://covers.openlibrary.org/b/isbn/9780374528379-L.jpg')," +
                "('9789712719387','Ang Pag-ibig ni Florante',2,12,'Anvil Publishing',1838,'Modern Edition',5,5,'Isang makatang akda ni Francisco Balagtas na nagpapakita ng tunay na pag-ibig sa bayan.','ebook_40.html','Shelf J-1','Filipino',160,'https://covers.openlibrary.org/b/isbn/9789712719387-L.jpg')," +
                "('9789712719394','Banaag at Sikat',33,12,'Ateneo de Manila',1906,'Modern Edition',4,4,'Ang unang sosyalistang nobela sa Pilipinas tungkol sa pakikibaka ng mga manggagawa.','ebook_41.html','Shelf J-2','Filipino',320,'https://covers.openlibrary.org/b/isbn/9789712719394-L.jpg')," +
                "('9789712719400','Mga Ibong Mandaragit',34,12,'Ateneo de Manila',1969,'Modern Edition',4,4,'Nobelang nagpapakita ng katiwalian sa lipunang Pilipino at pakikibaka ng mga dukha.','ebook_42.html','Shelf J-3','Filipino',280,'https://covers.openlibrary.org/b/isbn/9789712719400-L.jpg')," +
                "('9789712719417','Sa Mga Kuko ng Liwanag',35,12,'Ateneo de Manila',1986,'Modern Edition',4,4,'Ang kwento ni Julio Madiaga na pumunta sa Maynila upang hanapin ang kanyang minamahal.','ebook_43.html','Shelf J-4','Filipino',240,'https://covers.openlibrary.org/b/isbn/9789712719417-L.jpg')," +
                "('9789712719424','Luha ng Buwaya',34,12,'Ateneo de Manila',1972,'Modern Edition',4,4,'Nobelang nagpapakita ng tunay na kalagayan ng mga magsasaka at pakikibaka para sa katarungan.','ebook_44.html','Shelf J-5','Filipino',260,'https://covers.openlibrary.org/b/isbn/9789712719424-L.jpg')," +
                "('9780142437223','The Divine Comedy',36,15,'Penguin Classics',1320,'Penguin Edition',3,3,'Dante journey through Hell, Purgatory, and Paradise guided by Virgil and Beatrice.','ebook_45.html','Shelf K-1','English',798,'https://covers.openlibrary.org/b/isbn/9780142437223-L.jpg')," +
                "('9780140424393','Paradise Lost',37,15,'Penguin Classics',1667,'Penguin Edition',3,3,'An epic poem about the fall of Satan and the expulsion of Adam and Eve from Eden.','ebook_46.html','Shelf K-2','English',453,'https://covers.openlibrary.org/b/isbn/9780140424393-L.jpg')," +
                "('9780141439495','Gullivers Travels',38,17,'Penguin Classics',1726,'Penguin Edition',4,4,'Lemuel Gulliver travels to fantastical lands including Lilliput and Brobdingnag.','ebook_47.html','Shelf K-3','English',306,'https://covers.openlibrary.org/b/isbn/9780141439495-L.jpg')," +
                "('9780141439587','Robinson Crusoe',39,17,'Penguin Classics',1719,'Penguin Edition',4,4,'A man stranded on a remote tropical island for 28 years in this classic adventure story.','ebook_48.html','Shelf K-4','English',320,'https://covers.openlibrary.org/b/isbn/9780141439587-L.jpg')," +
                "('9780140443530','The Hunchback of Notre-Dame',40,11,'Penguin Classics',1831,'Penguin Edition',3,3,'The story of Quasimodo, the deformed bell-ringer of Notre-Dame Cathedral.','ebook_49.html','Shelf K-5','English',512,'https://covers.openlibrary.org/b/isbn/9780140443530-L.jpg')," +
                "('9780140449068','Around the World in 80 Days',15,17,'Penguin Classics',1872,'Penguin Edition',5,5,'Phileas Fogg bets he can travel around the entire world in just 80 days.','ebook_50.html','Shelf K-6','English',256,'https://covers.openlibrary.org/b/isbn/9780140449068-L.jpg')"
            );

            // Fix available_copies to match total_copies for all books (in case they got set to 0)
            st.executeUpdate(
                "UPDATE books SET available_copies = total_copies WHERE available_copies = 0 AND total_copies > 0"
            );

            System.out.println("[DatabaseInitializer] Database initialized successfully.");

        } catch (SQLException e) {
            System.err.println("[DatabaseInitializer] Error: " + e.getMessage());
        }
    }
}
