package com.pahinaconnect.model;

import java.sql.Timestamp;

public class BorrowRequest {
    private int id;
    private int bookId;
    private String bookTitle;
    private String bookIsbn;
    private int studentId;
    private String studentName;
    private String studentIdCode;
    private String studentEmail;
    private Timestamp requestedAt;
    private java.sql.Date preferredReturnDate;
    private String status;
    private String notes;
    private int reviewedBy;
    private Timestamp reviewedAt;

    public BorrowRequest() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public String getBookIsbn() { return bookIsbn; }
    public void setBookIsbn(String bookIsbn) { this.bookIsbn = bookIsbn; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentIdCode() { return studentIdCode; }
    public void setStudentIdCode(String studentIdCode) { this.studentIdCode = studentIdCode; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public Timestamp getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Timestamp requestedAt) { this.requestedAt = requestedAt; }

    public java.sql.Date getPreferredReturnDate() { return preferredReturnDate; }
    public void setPreferredReturnDate(java.sql.Date preferredReturnDate) { this.preferredReturnDate = preferredReturnDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public int getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(int reviewedBy) { this.reviewedBy = reviewedBy; }

    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }
}
