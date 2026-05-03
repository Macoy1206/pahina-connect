<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Borrow Requests - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📥 Borrow Requests</span>
      <c:if test="${pendingCount gt 0}">
        <span class="badge badge-danger" style="font-size:0.9rem;padding:6px 14px">${pendingCount} Pending</span>
      </c:if>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>
      <c:if test="${not empty param.success}">
        <c:choose>
          <c:when test="${param.success eq 'approved'}">
            <div class="alert alert-success" data-auto-dismiss>✅ Request approved and book issued successfully!</div>
          </c:when>
          <c:when test="${param.success eq 'rejected'}">
            <div class="alert alert-info" data-auto-dismiss>Request rejected and student notified.</div>
          </c:when>
        </c:choose>
      </c:if>

      <!-- Pending Requests -->
      <div class="card mb-3">
        <div class="card-header">
          <h3>⏳ Pending Requests (${pendingRequests.size()})</h3>
        </div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Student</th><th>Book</th><th>Requested</th><th>Preferred Return</th><th>Actions</th></tr>
              </thead>
              <tbody>
                <c:forEach var="r" items="${pendingRequests}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td>
                      <strong>${r.studentName}</strong><br>
                      <small class="text-muted">${r.studentIdCode}</small><br>
                      <small class="text-muted">${r.studentEmail}</small>
                    </td>
                    <td>
                      <strong>${r.bookTitle}</strong><br>
                      <small class="text-muted">ISBN: ${r.bookIsbn}</small>
                    </td>
                    <td><fmt:formatDate value="${r.requestedAt}" pattern="MMM dd, yyyy"/><br>
                      <small class="text-muted"><fmt:formatDate value="${r.requestedAt}" pattern="hh:mm a"/></small>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty r.preferredReturnDate}">
                          <span style="color:var(--danger);font-weight:700">
                            <fmt:formatDate value="${r.preferredReturnDate}" pattern="MMM dd, yyyy"/>
                          </span>
                        </c:when>
                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="d-flex gap-1">
                        <!-- Approve button -->
                        <button class="btn btn-sm btn-primary"
                                onclick="approveRequest(${r.id}, '${r.studentName.replace("'","\\'")}', '${r.bookTitle.replace("'","\\'")}')">
                          ✅ Approve
                        </button>
                        <!-- Reject button -->
                        <form method="post" action="${pageContext.request.contextPath}/admin/borrow-requests" style="display:inline"
                              data-confirm="The request from ${r.studentName} for &quot;${r.bookTitle}&quot; will be rejected."
                              data-confirm-title="Reject Request?"
                              data-confirm-type="danger"
                              data-confirm-icon="❌"
                              data-confirm-ok="Yes, Reject"
                              data-confirm-cancel="Cancel">
                          <input type="hidden" name="action" value="reject">
                          <input type="hidden" name="requestId" value="${r.id}">
                          <button type="submit" class="btn btn-sm btn-danger">❌ Reject</button>
                        </form>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty pendingRequests}">
                  <tr><td colspan="6" class="text-center text-muted" style="padding:30px">
                    🎉 No pending requests!
                  </td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- All Requests History -->
      <div class="card">
        <div class="card-header"><h3>📋 All Requests History</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Student</th><th>Book</th><th>Requested</th><th>Status</th></tr>
              </thead>
              <tbody>
                <c:forEach var="r" items="${allRequests}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td>${r.studentName}<br><small class="text-muted">${r.studentIdCode}</small></td>
                    <td>${r.bookTitle}</td>
                    <td><fmt:formatDate value="${r.requestedAt}" pattern="MMM dd, yyyy"/></td>
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
                        <c:when test="${r.status eq 'cancelled'}">
                          <span class="badge badge-info">Cancelled</span>
                        </c:when>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty allRequests}">
                  <tr><td colspan="5" class="text-center text-muted" style="padding:20px">No requests yet.</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Approve Modal -->
<div class="modal-overlay" id="approveModal">
  <div class="modal">
    <div class="modal-header">
      <h3>✅ Approve Borrow Request</h3>
      <button class="modal-close" data-modal-close>✕</button>
    </div>
    <div class="modal-body">
      <div id="approveDetails" style="padding:14px;background:var(--cream);border-radius:var(--radius-sm);margin-bottom:16px"></div>
      <form method="post" action="${pageContext.request.contextPath}/admin/borrow-requests">
        <input type="hidden" name="action" value="approve">
        <input type="hidden" name="requestId" id="approveRequestId">
        <div class="form-group">
          <label class="form-label">Loan Duration <span class="required">*</span></label>
          <select name="dueDays" class="form-control">
            <option value="7">7 days (1 week)</option>
            <option value="14" selected>14 days (2 weeks)</option>
            <option value="21">21 days (3 weeks)</option>
            <option value="30">30 days (1 month)</option>
          </select>
        </div>
        <div class="modal-footer" style="padding:0;border:none;margin-top:16px">
          <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
          <button type="submit" class="btn btn-primary">✅ Approve & Issue Book</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
function approveRequest(id, student, book) {
  document.getElementById('approveRequestId').value = id;
  document.getElementById('approveDetails').innerHTML =
    '<p><strong>Student:</strong> ' + student + '</p>' +
    '<p style="margin-top:6px"><strong>Book:</strong> ' + book + '</p>';
  openModal('approveModal');
}
</script>
</body>
</html>
