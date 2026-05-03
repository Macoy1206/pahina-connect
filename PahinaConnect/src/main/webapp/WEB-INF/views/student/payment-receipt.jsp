<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Payment Receipt - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
  <style>
    @media print {
      .no-print { display:none !important; }
      .wrapper { display:block !important; }
      .sidebar { display:none !important; }
      .main-content { margin:0 !important; padding:0 !important; }
      .topbar { display:none !important; }
      body { background:#fff !important; }
      .receipt-card { box-shadow:none !important; border:1px solid #ccc !important; }
    }
    .receipt-card {
      max-width:520px; margin:0 auto;
      background:#fff; border-radius:12px;
      box-shadow:0 4px 24px rgba(27,58,107,0.12);
      overflow:hidden;
    }
    .receipt-header {
      background:linear-gradient(135deg,var(--navy-dark),var(--navy));
      color:#fff; padding:28px 32px; text-align:center;
    }
    .receipt-header h2 { margin:0 0 4px; font-size:1.4rem; }
    .receipt-header p  { margin:0; opacity:0.8; font-size:0.88rem; }
    .receipt-body { padding:28px 32px; }
    .receipt-ref {
      background:var(--cream); border:2px dashed var(--gold);
      border-radius:8px; padding:14px 20px; text-align:center;
      margin-bottom:24px;
    }
    .receipt-ref .ref-label { font-size:0.78rem; color:var(--text-light); text-transform:uppercase; letter-spacing:1px; }
    .receipt-ref .ref-number { font-size:1.4rem; font-weight:800; color:var(--navy-dark); letter-spacing:2px; }
    .receipt-row {
      display:flex; justify-content:space-between; align-items:flex-start;
      padding:9px 0; border-bottom:1px solid var(--cream-dark); font-size:0.9rem;
    }
    .receipt-row:last-child { border-bottom:none; }
    .receipt-row .label { color:var(--text-light); flex-shrink:0; margin-right:12px; }
    .receipt-row .value { font-weight:600; color:var(--navy-dark); text-align:right; }
    .receipt-total {
      background:var(--navy); color:#fff; border-radius:8px;
      padding:16px 20px; margin:20px 0; display:flex;
      justify-content:space-between; align-items:center;
    }
    .receipt-total .total-label { font-size:0.9rem; opacity:0.85; }
    .receipt-total .total-amount { font-size:1.6rem; font-weight:800; color:var(--gold); }
    .receipt-footer {
      background:var(--cream); padding:16px 32px; text-align:center;
      font-size:0.8rem; color:var(--text-light); border-top:1px solid var(--cream-dark);
    }
    .paid-stamp {
      display:inline-block; border:3px solid var(--success);
      color:var(--success); font-weight:800; font-size:1.1rem;
      padding:6px 20px; border-radius:6px; transform:rotate(-3deg);
      letter-spacing:3px; margin-bottom:16px;
    }
    .method-badge {
      display:inline-flex; align-items:center; gap:6px;
      background:var(--cream); border:1px solid var(--cream-dark);
      border-radius:20px; padding:4px 12px; font-size:0.85rem;
    }
  </style>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/student-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar no-print">
      <span class="topbar-title">🧾 Payment Receipt</span>
      <div style="display:flex;gap:8px">
        <button onclick="window.print()" class="btn btn-gold btn-sm">🖨️ Print Receipt</button>
        <a href="${pageContext.request.contextPath}/student/my-books" class="btn btn-outline btn-sm">← Back to My Books</a>
      </div>
    </div>
    <div class="page-content">

      <div class="receipt-card">
        <!-- Header -->
        <div class="receipt-header">
          <div style="font-size:2.5rem;margin-bottom:8px">📚</div>
          <h2>Pahina Connect</h2>
          <p>Library Management System</p>
          <p style="margin-top:6px;font-size:0.8rem;opacity:0.7">Official Fine Payment Receipt</p>
        </div>

        <!-- Body -->
        <div class="receipt-body">

          <!-- Paid stamp -->
          <div style="text-align:center;margin-bottom:20px">
            <div class="paid-stamp">✓ PAID</div>
          </div>

          <!-- Reference number -->
          <div class="receipt-ref">
            <div class="ref-label">Reference Number</div>
            <div class="ref-number">${refNumber}</div>
          </div>

          <!-- Details -->
          <div class="receipt-row">
            <span class="label">📅 Date Paid</span>
            <span class="value"><fmt:formatDate value="${paidAt}" pattern="MMMM dd, yyyy hh:mm a"/></span>
          </div>
          <div class="receipt-row">
            <span class="label">👤 Student</span>
            <span class="value">${studentName}</span>
          </div>
          <div class="receipt-row">
            <span class="label">🎓 Student ID</span>
            <span class="value"><code>${studentCode}</code></span>
          </div>
          <div class="receipt-row">
            <span class="label">📖 Book</span>
            <span class="value">${bookTitle}</span>
          </div>
          <div class="receipt-row">
            <span class="label">🔖 ISBN</span>
            <span class="value"><code>${isbn}</code></span>
          </div>
          <div class="receipt-row">
            <span class="label">📤 Issue Date</span>
            <span class="value"><fmt:formatDate value="${issueDate}" pattern="MMM dd, yyyy"/></span>
          </div>
          <div class="receipt-row">
            <span class="label">⏰ Due Date</span>
            <span class="value"><fmt:formatDate value="${dueDate}" pattern="MMM dd, yyyy"/></span>
          </div>
          <c:if test="${not empty returnDate}">
          <div class="receipt-row">
            <span class="label">↩️ Return Date</span>
            <span class="value"><fmt:formatDate value="${returnDate}" pattern="MMM dd, yyyy"/></span>
          </div>
          </c:if>
          <div class="receipt-row">
            <span class="label">💳 Payment Method</span>
            <span class="value">
              <span class="method-badge">
                <c:choose>
                  <c:when test="${paymentMethod eq 'GCash'}">💙</c:when>
                  <c:when test="${paymentMethod eq 'Maya'}">💚</c:when>
                  <c:when test="${paymentMethod eq 'Cash'}">💵</c:when>
                  <c:when test="${paymentMethod eq 'Bank Transfer'}">🏦</c:when>
                  <c:otherwise>💳</c:otherwise>
                </c:choose>
                ${paymentMethod}
              </span>
            </span>
          </div>

          <!-- Total -->
          <div class="receipt-total">
            <span class="total-label">Fine Amount Paid</span>
            <span class="total-amount">₱<fmt:formatNumber value="${amount}" pattern="#,##0.00"/></span>
          </div>

          <!-- Action buttons -->
          <div class="no-print" style="display:flex;gap:10px;margin-top:8px">
            <button onclick="window.print()" class="btn btn-primary" style="flex:1">🖨️ Print Receipt</button>
            <a href="${pageContext.request.contextPath}/student/my-books" class="btn btn-outline" style="flex:1">← My Books</a>
          </div>
        </div>

        <!-- Footer -->
        <div class="receipt-footer">
          <p style="margin:0 0 4px">This is an official receipt from Pahina Connect Library.</p>
          <p style="margin:0">Please keep this receipt for your records.</p>
          <p style="margin:6px 0 0;font-size:0.75rem;opacity:0.7">Generated: <fmt:formatDate value="${paidAt}" pattern="MMMM dd, yyyy hh:mm a"/></p>
        </div>
      </div>

    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
