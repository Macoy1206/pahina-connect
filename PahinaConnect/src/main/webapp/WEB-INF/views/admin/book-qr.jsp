<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Book QR Code - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📱 Book QR Code</span>
      <a href="${pageContext.request.contextPath}/admin/books" class="btn btn-outline btn-sm">← Back</a>
    </div>
    <div class="page-content">
      <div style="max-width:500px;margin:auto">
        <div class="card">
          <div class="card-header"><h3>📱 QR Code for: ${book.title}</h3></div>
          <div class="card-body text-center">
            <p style="color:var(--text-light);margin-bottom:20px">ISBN: <strong>${book.isbn}</strong></p>

            <div id="qrContainer" class="qr-container">
              <div class="spinner"></div>
            </div>

            <div style="margin-top:20px">
              <button onclick="generateQR(${book.id})" class="btn btn-primary">🔄 Regenerate QR</button>
              <button onclick="printQR()" class="btn btn-outline no-print">🖨️ Print</button>
            </div>

            <div style="margin-top:20px;padding:14px;background:var(--cream);border-radius:var(--radius-sm);text-align:left">
              <p style="font-size:0.85rem;color:var(--text-light)"><strong>Book Details:</strong></p>
              <p style="font-size:0.85rem">Title: ${book.title}</p>
              <p style="font-size:0.85rem">Author: ${book.authorName}</p>
              <p style="font-size:0.85rem">Category: ${book.categoryName}</p>
              <p style="font-size:0.85rem">Location: ${book.location}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
// Auto-generate on load
window.addEventListener('load', function() { generateQR(${book.id}); });
function printQR() { window.print(); }
</script>
</body>
</html>
