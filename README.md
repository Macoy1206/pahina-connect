# Pahina Connect - Library Management System

## Quick Start

1. **Start the system:** Double-click `START_PAHINA_CONNECT.bat`
2. **Build & Deploy:** Double-click `BUILD_AND_FIX.bat`
3. **Open browser:** http://localhost:8080/PahinaConnect

## Login Credentials

| Role    | Email                          | Password    |
|---------|-------------------------------|-------------|
| Admin   | admin@pahinaconnect.com        | Admin@123   |
| Student | juan.delacruz@student.com      | Student@123 |

## Project Structure

```
Pahina_connect/
├── PahinaConnect/          ← Main Java/Maven project
│   ├── src/main/java/      ← Java source files
│   ├── src/main/webapp/    ← JSP, CSS, JS, HTML files
│   └── database/           ← Schema SQL file
├── docs/
│   └── sql/
│       └── MASTER_SETUP_ALL.sql  ← Run this in MySQL Workbench
├── START_PAHINA_CONNECT.bat      ← Start MySQL + Tomcat
├── BUILD_AND_FIX.bat             ← Build and deploy
├── SETUP_DATABASE.bat            ← Setup database only
└── STOP_PAHINA_CONNECT.bat       ← Stop all services
```

## Database Setup

Run `docs/sql/MASTER_SETUP_ALL.sql` in MySQL Workbench to insert all 50 books, 40 authors, and 18 categories.

## Tech Stack

- **Backend:** Java Servlets (Jakarta EE)
- **Frontend:** JSP, HTML, CSS, JavaScript
- **Database:** MySQL 8.0
- **Server:** Apache Tomcat 10.1
- **Build:** Maven
