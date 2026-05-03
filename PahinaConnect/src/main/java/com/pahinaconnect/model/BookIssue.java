package com.pahinaconnect.model;

import java.sql.Timestamp;

public class BookIssue {
    private int id;
    private int bookId;
    private String bookTitle;
    private String bookIsbn;
    private int studentId;
    private String studentName;
    private String studentIdCode;
    private Timestamp issueDate;
    private Timestamp dueDate;
    private Timestamp returnDate;
    private double fineAmount;
    private boolean finePaid;
    private String status;
    private int issuedBy;
    private String notes;
    private String studentEmail; // for email reminders (not stored in DB, joined from users)

    public BookIssue() {}

    // Getters and Setters
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

    public Timestamp getIssueDate() { return issueDate; }
    public void setIssueDate(Timestamp issueDate) { this.issueDate = issueDate; }

    public Timestamp getDueDate() { return dueDate; }
    public void setDueDate(Timestamp dueDate) { this.dueDate = dueDate; }

    public Timestamp getReturnDate() { return returnDate; }
    public void setReturnDate(Timestamp returnDate) { this.returnDate = returnDate; }

    public double getFineAmount() { return fineAmount; }
    public void setFineAmount(double fineAmount) { this.fineAmount = fineAmount; }

    public boolean isFinePaid() { return finePaid; }
    public void setFinePaid(boolean finePaid) { this.finePaid = finePaid; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getIssuedBy() { return issuedBy; }
    public void setIssuedBy(int issuedBy) { this.issuedBy = issuedBy; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public boolean isOverdue() {
        if (returnDate != null) return false;
        return dueDate != null && dueDate.before(new java.util.Date());
    }

    public long getDaysOverdue() {
        if (!isOverdue()) return 0;
        long diff = System.currentTimeMillis() - dueDate.getTime();
        return diff / (1000 * 60 * 60 * 24);
    }
}
