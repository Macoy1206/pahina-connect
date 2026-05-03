<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Student Detail - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">👤 Student Detail</span>
      <a href="${pageContext.request.contextPath}/admin/students" class="btn btn-outline btn-sm">← Back</a>
    </div>
    <div class="page-content">
      <div class="grid grid-2 mb-3">
        <!-- Student Info -->
        <div class="card">
          <div class="card-header"><h3>👤 Personal Information</h3></div>
          <div class="card-body">
            <table style="width:100%;font-size:0.9rem;border-collapse:collapse">
              <tr style="border-bottom:1px solid var(--cream-dark)">
                <td style="padding:8px 0;color:var(--text-light);width:40%">Student ID</td>
                <td><code style="font-size:1rem;font-weight:700;color:var(--green)">${student.studentId}</code></td>
              </tr>
              <tr style="border-bottom:1px solid var(--cream-dark)">
                <td style="padding:8px 0;color:var(--text-light)">Full Name</td>
                <td><strong>${student.fullName}</strong></td>
              </tr>
              <tr style="border-bottom:1px solid var(--cream-dark)">
                <td style="padding:8px 0;color:var(--text-light)">Email</td>
                <td>${student.email}</td>
              </tr>
              <tr style="border-bottom:1px solid var(--cream-dark)">
                <td style="padding:8px 0;color:var(--text-light)">Phone</td>
                <td>${student.phone}</td>
              </tr>
              <tr style="border-bottom:1px solid var(--cream-dark)">
                <td style="padding:8px 0;color:var(--text-light)">Gender</td>
                <td>${student.gender}</td>
              </tr>
              <tr style="border-bottom:1px solid var(--cream-dark)">
                <td style="padding:8px 0;color:var(--text-light)">Date of Birth</td>
                <td><fmt:formatDate value="${student.dateOfBirth}" pattern="MMMM dd, yyyy"/></td>
              </tr>
              <tr style="border-bottom:1px solid var(--cream-dark)">
                <td style="padding:8px 0;color:var(--text-light)">Address</td>
                <td>${student.address}</td>
              </tr>
              <tr>
                <td style="padding:8px 0;color:var(--text-light)">Status</td>
                <td>
                  <c:choose>
                    <c:when test="${student.active}"><span class="badge badge-success">Active</span></c:when>
                    <c:otherwise><span class="badge badge-danger">Inactive</span></c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </table>
            <div class="d-flex gap-1 mt-2">
              <a href="${pageContext.request.contextPath}/admin/issue-book?studentId=${student.studentId}"
                 class="btn btn-primary btn-sm">📤 Issue Book</a>
            </div>
          </div>
        </div>

        <!-- Stats -->
        <div class="card">
          <div class="card-header"><h3>📊 Borrowing Statistics</h3></div>
          <div class="card-body">
            <div class="grid grid-2">
              <div class="stat-card" style="padding:14px">
                <div class="stat-icon" style="width:40px;height:40px;font-size:1.2rem">📚</div>
                <div>
                  <div class="stat-value" style="font-size:1.4rem">${issues.size()}</div>
                  <div class="stat-label">Total Borrowed</div>
                </div>
              </div>
              <div class="stat-card danger" style="padding:14px">
                <div class="stat-icon" style="width:40px;height:40px;font-size:1.2rem">⚠️</div>
                <div>
                  <div class="stat-value" style="font-size:1.4rem">
                    <c:set var="overdueCount" value="0"/>
                    <c:forEach var="i" items="${issues}">
                      <c:if test="${i.status eq 'overdue'}"><c:set var="overdueCount" value="${overdueCount+1}"/></c:if>
                    </c:forEach>
                    ${overdueCount}
                  </div>
                  <div class="stat-label">Overdue</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Borrow Requests -->
      <div class="card mb-3">
        <div class="card-header">
          <h3>📥 Borrow Requests</h3>
          <span style="color:rgba(255,255,255,0.7);font-size:0.82rem">${borrowRequests.size()} total</span>
        </div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Book</th>
                  <th>Requested On</th>
                  <th>Preferred Return Date</th>
                  <th>Notes</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="r" items="${borrowRequests}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td>
                      <strong>${r.bookTitle}</strong><br>
                      <small class="text-muted">${r.bookIsbn}</small>
                    </td>
                    <td>
                      <fmt:formatDate value="${r.requestedAt}" pattern="MMM dd, yyyy"/><br>
                      <small class="text-muted"><fmt:formatDate value="${r.requestedAt}" pattern="hh:mm a"/></small>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty r.preferredReturnDate}">
                          <span style="font-weight:700;color:var(--danger)">
                            <fmt:formatDate value="${r.preferredReturnDate}" pattern="MMM dd, yyyy"/>
                          </span>
                        </c:when>
                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td style="max-width:160px;font-size:0.82rem;color:var(--text-mid)">
                      <c:choose>
                        <c:when test="${not empty r.notes}">${r.notes}</c:when>
                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.status eq 'pending'}"><span class="badge badge-warning">⏳ Pending</span></c:when>
                        <c:when test="${r.status eq 'approved'}"><span class="badge badge-success">✅ Approved</span></c:when>
                        <c:when test="${r.status eq 'rejected'}"><span class="badge badge-danger">❌ Rejected</span></c:when>
                        <c:when test="${r.status eq 'cancelled'}"><span class="badge badge-info">Cancelled</span></c:when>
                        <c:otherwise><span class="badge badge-info">${r.status}</span></c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty borrowRequests}">
                  <tr>
                    <td colspan="6" class="text-center text-muted" style="padding:24px">
                      No borrow requests from this student.
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Borrowing History -->
      <div class="card">
        <div class="card-header"><h3>📖 Borrowing History</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Book</th><th>Issue Date</th><th>Due Date</th><th>Return Date</th><th>Fine</th><th>Status</th></tr>
              </thead>
              <tbody>
                <c:forEach var="issue" items="${issues}" varStatus="s">
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
                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${issue.fineAmount gt 0}">
                        <span class="${issue.finePaid ? 'text-muted' : 'text-danger'}">
                          ₱<fmt:formatNumber value="${issue.fineAmount}" pattern="#,##0.00"/>
                          <c:if test="${issue.finePaid}"> (paid)</c:if>
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
                  </tr>
                </c:forEach>
                <c:if test="${empty issues}">
                  <tr><td colspan="7" class="text-center text-muted" style="padding:20px">No borrowing history.</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
