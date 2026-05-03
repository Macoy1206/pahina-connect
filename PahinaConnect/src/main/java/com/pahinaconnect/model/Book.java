package com.pahinaconnect.model;

import java.sql.Timestamp;

public class Book {
    private int id;
    private String isbn;
    private String title;
    private int authorId;
    private String authorName;
    private int categoryId;
    private String categoryName;
    private String publisher;
    private int publicationYear;
    private String edition;
    private int totalCopies;
    private int availableCopies;
    private String description;
    private String coverImage;
    private String ebookFile;
    private String qrCode;
    private String barcode;
    private String location;
    private String language;
    private int pages;
    private boolean isActive;
    private Timestamp createdAt;

    public Book() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public int getAuthorId() { return authorId; }
    public void setAuthorId(int authorId) { this.authorId = authorId; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }

    public int getPublicationYear() { return publicationYear; }
    public void setPublicationYear(int publicationYear) { this.publicationYear = publicationYear; }

    public String getEdition() { return edition; }
    public void setEdition(String edition) { this.edition = edition; }

    public int getTotalCopies() { return totalCopies; }
    public void setTotalCopies(int totalCopies) { this.totalCopies = totalCopies; }

    public int getAvailableCopies() { return availableCopies; }
    public void setAvailableCopies(int availableCopies) { this.availableCopies = availableCopies; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }

    public String getEbookFile() { return ebookFile; }
    public void setEbookFile(String ebookFile) { this.ebookFile = ebookFile; }

    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }

    public int getPages() { return pages; }
    public void setPages(int pages) { this.pages = pages; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isAvailable() { return availableCopies > 0; }
}
