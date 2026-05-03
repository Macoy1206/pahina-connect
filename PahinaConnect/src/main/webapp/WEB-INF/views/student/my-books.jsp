<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>My Books - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/student-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📚 My Books</span>
      <a href="${pageContext.request.contextPath}/search" class="btn btn-primary btn-sm">🔍 Find Books</a>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <!-- Borrow Requests -->
      <div class="card mb-3">
        <div class="card-header">
          <h3>📥 My Borrow Requests (${borrowRequests.size()})</h3>
          <a href="${pageContext.request.contextPath}/search" class="btn btn-sm btn-primary">+ New Request</a>
        </div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Book</th><th>Requested</th><th>Preferred Return</th><th>Status</th><th>Action</th></tr>
              </thead>
              <tbody>
                <c:forEach var="r" items="${borrowRequests}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td><strong>${r.bookTitle}</strong><br><small class="text-muted">${r.bookIsbn}</small></td>
                    <td><fmt:formatDate value="${r.requestedAt}" pattern="MMM dd, yyyy hh:mm a"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty r.preferredReturnDate}">
                          <span style="color:var(--danger);font-weight:600">
                            <fmt:formatDate value="${r.preferredReturnDate}" pattern="MMM dd, yyyy"/>
                          </span>
                        </c:when>
                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.status eq 'pending'}">
                          <span class="badge badge-warning">⏳ Pending</span>
                        </c:when>
                        <c:when test="${r.status eq 'approved'}">
                          <span class="badge badge-success">✅ Approved</span>
                        </c:when>
                        <c:when test="${r.status eq 'rejected'}">
                          <span class="badge badge-danger">❌ Rejected</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-info">${r.status}</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${r.status eq 'pending'}">
                        <form method="post" action="${pageContext.request.contextPath}/borrow-request" style="display:inline"
                              data-confirm="Your pending borrow request for &quot;${r.bookTitle}&quot; will be cancelled."
                              data-confirm-title="Cancel Request?"
                              data-confirm-type="danger"
                              data-confirm-icon="❌"
                              data-confirm-ok="Yes, Cancel It"
                              data-confirm-cancel="Keep It">
                          <input type="hidden" name="action" value="cancel">
                          <input type="hidden" name="requestId" value="${r.id}">
                          <button type="submit" class="btn btn-sm btn-danger">Cancel</button>
                        </form>
                      </c:if>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty borrowRequests}">
                  <tr><td colspan="6" class="text-center text-muted" style="padding:24px">
                    No borrow requests yet.
                    <a href="${pageContext.request.contextPath}/search">Browse books to request one!</a>
                  </td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Active Issues -->
      <div class="card mb-3">
        <div class="card-header"><h3>📤 Currently Borrowed (${activeIssues.size()})</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Book Title</th><th>ISBN</th><th>Issue Date</th><th>Due Date</th><th>Status</th><th>Fine</th><th>Action</th></tr>
              </thead>
              <tbody>
                <c:forEach var="issue" items="${activeIssues}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td><strong>${issue.bookTitle}</strong></td>
                    <td><code>${issue.bookIsbn}</code></td>
                    <td><fmt:formatDate value="${issue.issueDate}" pattern="MMM dd, yyyy"/></td>
                    <td>
                      <fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${issue.status eq 'overdue'}">
                          <span class="badge badge-danger">Overdue (${issue.daysOverdue} days)</span>
                        </c:when>
                        <c:otherwise><span class="badge badge-success">Active</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${issue.status eq 'overdue'}">
                        <span class="text-danger fw-bold">₱<fmt:formatNumber value="${issue.daysOverdue * 5.0}" pattern="#,##0.00"/></span>
                      </c:if>
                      <c:if test="${issue.status ne 'overdue'}">—</c:if>
                    </td>
                    <td>—</td>
                  </tr>
                </c:forEach>
                <c:if test="${empty activeIssues}">
                  <tr><td colspan="7" class="text-center text-muted" style="padding:30px">
                    No books currently borrowed. <a href="${pageContext.request.contextPath}/search">Browse the library!</a>
                  </td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Reservations -->
      <div class="card mb-3">
        <div class="card-header"><h3>🔖 My Reservations (${reservations.size()})</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Book</th><th>Reserved On</th><th>Expires</th><th>Queue</th><th>Status</th><th>Action</th></tr>
              </thead>
              <tbody>
                <c:forEach var="r" items="${reservations}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td><strong>${r.bookTitle}</strong></td>
                    <td><fmt:formatDate value="${r.reservedAt}" pattern="MMM dd, yyyy"/></td>
                    <td><fmt:formatDate value="${r.expiresAt}" pattern="MMM dd, yyyy"/></td>
                    <td>#${r.queuePosition}</td>
                    <td>
                      <c:choose>
                        <c:when test="${r.status eq 'pending'}"><span class="badge badge-warning">Pending</span></c:when>
                        <c:when test="${r.status eq 'fulfilled'}"><span class="badge badge-success">Fulfilled</span></c:when>
                        <c:when test="${r.status eq 'cancelled'}"><span class="badge badge-danger">Cancelled</span></c:when>
                        <c:otherwise><span class="badge badge-info">${r.status}</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${r.status eq 'pending'}">
                        <form method="post" action="${pageContext.request.contextPath}/reserve" style="display:inline"
                              data-confirm="Your reservation for &quot;${r.bookTitle}&quot; will be cancelled."
                              data-confirm-title="Cancel Reservation?"
                              data-confirm-type="danger"
                              data-confirm-icon="🔖"
                              data-confirm-ok="Yes, Cancel"
                              data-confirm-cancel="Keep It">
                          <input type="hidden" name="action" value="cancel">
                          <input type="hidden" name="reservationId" value="${r.id}">
                          <button type="submit" class="btn btn-sm btn-danger">Cancel</button>
                        </form>
                      </c:if>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty reservations}">
                  <tr><td colspan="7" class="text-center text-muted" style="padding:20px">No reservations.</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Borrowing History -->
      <div class="card">
        <div class="card-header"><h3>📖 Borrowing History (${allIssues.size()})</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Book</th><th>Issue Date</th><th>Due Date</th><th>Return Date</th><th>Fine</th><th>Status</th><th>Action</th></tr>
              </thead>
              <tbody>
                <c:forEach var="issue" items="${allIssues}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td>${issue.bookTitle}</td>
                    <td><fmt:formatDate value="${issue.issueDate}" pattern="MMM dd, yyyy"/></td>
                    <td><fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty issue.returnDate}">
                          <fmt:formatDate value="${issue.returnDate}" pattern="MMM dd, yyyy"/>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${issue.fineAmount gt 0}">
                        <span class="${issue.finePaid ? 'text-muted' : 'text-danger'}">
                          ₱<fmt:formatNumber value="${issue.fineAmount}" pattern="#,##0.00"/>
                          <c:if test="${issue.finePaid}"> ✓</c:if>
                        </span>
                      </c:if>
                      <c:if test="${issue.fineAmount eq 0}">—</c:if>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${issue.status eq 'returned'}"><span class="badge badge-success">Returned</span></c:when>
                        <c:when test="${issue.status eq 'overdue'}"><span class="badge badge-danger">Overdue</span></c:when>
                        <c:otherwise><span class="badge badge-info">Active</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${issue.fineAmount gt 0 and not issue.finePaid}">
                        <button class="btn btn-sm btn-danger"
                                onclick="openPayModal(${issue.id},'${issue.bookTitle.replace("'","\\'")}',${issue.fineAmount})">
                          💳 Pay Fine
                        </button>
                      </c:if>
                      <c:if test="${issue.finePaid}">
                        <span style="color:var(--success);font-size:0.82rem;font-weight:600">✅ Paid</span>
                      </c:if>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty allIssues}">
                  <tr><td colspan="7" class="text-center text-muted" style="padding:20px">No borrowing history yet.</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- ── Pay Fine Modal ─────────────────────────────────────────────────────── -->
<div class="modal-overlay" id="payFineModal">
  <div class="modal" style="max-width:480px">
    <div class="modal-header" style="background:var(--danger)">
      <h3 style="color:#fff">💳 Pay Library Fine</h3>
      <button class="modal-close" data-modal-close>✕</button>
    </div>
    <div class="modal-body">

      <!-- Fine summary -->
      <div style="background:var(--cream);border-left:4px solid var(--danger);border-radius:8px;padding:16px;margin-bottom:20px">
        <p style="margin:0 0 4px;font-size:0.82rem;color:var(--text-light)">Book</p>
        <p id="payBookTitle" style="margin:0 0 12px;font-weight:700;color:var(--navy-dark);font-size:1rem"></p>
        <p style="margin:0 0 4px;font-size:0.82rem;color:var(--text-light)">Fine Amount</p>
        <p id="payFineAmount" style="margin:0;font-size:1.8rem;font-weight:800;color:var(--danger)"></p>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/student/fine-payment" id="payFineForm">
        <input type="hidden" name="action" value="pay">
        <input type="hidden" name="issueId" id="payIssueId">

        <!-- Payment method -->
        <div class="form-group">
          <label class="form-label">Payment Method <span class="required">*</span></label>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:6px">
            <label style="cursor:pointer">
              <input type="radio" name="paymentMethod" value="Cash" required style="display:none" class="pay-method-radio">
              <div class="pay-method-card" style="border:2px solid var(--cream-dark);border-radius:8px;padding:12px;text-align:center;transition:all 0.2s">
                <div style="font-size:1.6rem">💵</div>
                <div style="font-size:0.85rem;font-weight:600;margin-top:4px">Cash</div>
              </div>
            </label>
            <label style="cursor:pointer">
              <input type="radio" name="paymentMethod" value="GCash" style="display:none" class="pay-method-radio">
              <div class="pay-method-card" style="border:2px solid var(--cream-dark);border-radius:8px;padding:12px;text-align:center;transition:all 0.2s">
                <div style="font-size:1.6rem">💙</div>
                <div style="font-size:0.85rem;font-weight:600;margin-top:4px">GCash</div>
              </div>
            </label>
            <label style="cursor:pointer">
              <input type="radio" name="paymentMethod" value="Maya" style="display:none" class="pay-method-radio">
              <div class="pay-method-card" style="border:2px solid var(--cream-dark);border-radius:8px;padding:12px;text-align:center;transition:all 0.2s">
                <div style="font-size:1.6rem">💚</div>
                <div style="font-size:0.85rem;font-weight:600;margin-top:4px">Maya</div>
              </div>
            </label>
            <label style="cursor:pointer">
              <input type="radio" name="paymentMethod" value="Bank Transfer" style="display:none" class="pay-method-radio">
              <div class="pay-method-card" style="border:2px solid var(--cream-dark);border-radius:8px;padding:12px;text-align:center;transition:all 0.2s">
                <div style="font-size:1.6rem">🏦</div>
                <div style="font-size:0.85rem;font-weight:600;margin-top:4px">Bank Transfer</div>
              </div>
            </label>
          </div>
        </div>

        <!-- Notes -->
        <div class="form-group">
          <label class="form-label">Notes <span style="color:var(--text-light);font-weight:400">(optional)</span></label>
          <textarea name="notes" class="form-control" rows="2"
                    placeholder="e.g. Reference number, transaction ID..."></textarea>
        </div>

        <!-- Terms -->
        <div style="background:#FBF5E8;border:1px solid var(--gold);border-radius:8px;padding:12px;margin-bottom:16px;font-size:0.83rem;color:var(--navy-dark)">
          <strong>📋 Note:</strong> By confirming, you acknowledge that you are paying the library fine.
          A receipt will be generated automatically after payment.
        </div>

        <div class="modal-footer" style="padding:0;border:none">
          <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
          <button type="submit" class="btn btn-danger" id="confirmPayBtn">💳 Confirm Payment</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
function openPayModal(issueId, bookTitle, fineAmount) {
  document.getElementById('payIssueId').value   = issueId;
  document.getElementById('payBookTitle').textContent = bookTitle;
  document.getElementById('payFineAmount').textContent = '₱' + fineAmount.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  // Reset form
  document.getElementById('payFineForm').reset();
  document.querySelectorAll('.pay-method-card').forEach(function(c) {
    c.style.border = '2px solid var(--cream-dark)';
    c.style.background = '';
  });
  openModal('payFineModal');
}

// Payment method card selection
document.querySelectorAll('.pay-method-radio').forEach(function(radio) {
  radio.addEventListener('change', function() {
    document.querySelectorAll('.pay-method-card').forEach(function(c) {
      c.style.border = '2px solid var(--cream-dark)';
      c.style.background = '';
    });
    var card = this.nextElementSibling;
    card.style.border = '2px solid var(--navy)';
    card.style.background = 'var(--cream)';
  });
});

// Confirm payment with SweetAlert
document.getElementById('payFineForm').addEventListener('submit', function(e) {
  e.preventDefault();
  var method = document.querySelector('input[name="paymentMethod"]:checked');
  if (!method) {
    Swal.fire({ icon:'warning', title:'Select Payment Method', text:'Please choose a payment method to continue.' });
    return;
  }
  var amount = document.getElementById('payFineAmount').textContent;
  var book   = document.getElementById('payBookTitle').textContent;
  Swal.fire({
    icon: 'question',
    title: '💳 Confirm Payment',
    html: '<div style="text-align:left;padding:8px">' +
          '<p><strong>Book:</strong> ' + book + '</p>' +
          '<p><strong>Amount:</strong> <span style="color:#c0392b;font-weight:700">' + amount + '</span></p>' +
          '<p><strong>Method:</strong> ' + method.value + '</p>' +
          '</div>',
    showCancelButton: true,
    confirmButtonText: '✅ Yes, Pay Now',
    cancelButtonText: 'Cancel',
    reverseButtons: true
  }).then(function(result) {
    if (result.isConfirmed) {
      Swal.fire({ title:'Processing...', allowOutsideClick:false, didOpen:function(){ Swal.showLoading(); } });
      document.getElementById('payFineForm').submit();
    }
  });
});
</script>
</body>
</html>
