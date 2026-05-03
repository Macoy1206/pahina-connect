# 📚 Pahina Connect — Library Management System

## Setup Instructions

### 1. Database Setup
1. Open **MySQL Workbench** (root / root)
2. Run the script: `database/pahina_connect.sql`
3. This creates the `pahina_connect` database with all tables and seed data

### 2. Build the WAR
```
mvn clean package -DskipTests
```
Output: `target/PahinaConnect-1.0.0.war`

### 3. Deploy to Tomcat
1. Copy `PahinaConnect-1.0.0.war` to Tomcat's `webapps/` folder
2. Start Tomcat
3. Access: `http://localhost:8080/PahinaConnect-1.0.0/`

---

## Default Admin Login
- **Email:** `admin@pahinaconnect.com`
- **Password:** `Admin@123`

---

## Features
| Feature | Details |
|---|---|
| Admin Dashboard | Stats, quick actions, recent issues |
| Book Management | Add/Edit/Delete books, cover upload, e-book PDF upload |
| Category Management | Full CRUD |
| Author Management | Full CRUD |
| Issue Book | Search student by ID, select book, set loan duration |
| Return Book | Auto fine calculation (₱5/day, max ₱500) |
| Student Management | Search, view details, activate/deactivate |
| Analytics | Charts: monthly issues, category distribution, most borrowed |
| Student Registration | Full form with validation, auto Student ID, welcome email |
| Forgot Password | OTP via email (6-digit, 10-min expiry) |
| QR Code | Auto-generated per book, scannable via camera |
| Barcode | ISBN-based Code128 barcode |
| E-Book Viewer | In-browser PDF viewer + download |
| Reservation Queue | Students can reserve unavailable books |
| Advanced Search | Filter by category, author, availability, ISBN |
| Email Reminders | Due date reminders, overdue notices |
| Change Password | Both admin and student |

## Color Palette (60-30-10)
- **60%** `#F5F0E8` — Parchment/Cream (backgrounds)
- **30%** `#2C5F2E` — Forest Green (navigation, headers)
- **10%** `#E8A838` — Golden Amber (accents, highlights)
