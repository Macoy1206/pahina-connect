<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Admin Dashboard - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <div class="d-flex align-center gap-1">
        <button onclick="toggleSidebar()" class="btn btn-outline btn-sm" style="display:none" id="menuBtn">☰</button>
        <span class="topbar-title">📊 Admin Dashboard</span>
      </div>
      <div class="topbar-actions">
        <span style="font-size:0.85rem;color:var(--text-light)">
          <fmt:formatDate value="<%= new java.util.Date() %>" pattern="MMMM dd, yyyy"/>
        </span>
      </div>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <!-- Stats Grid -->
      <div class="grid grid-4 mb-3">
        <div class="stat-card">
          <div class="stat-icon">📚</div>
          <div>
            <div class="stat-value">${totalBooks}</div>
            <div class="stat-label">Total Books</div>
          </div>
        </div>
        <div class="stat-card gold">
          <div class="stat-icon">✅</div>
          <div>
            <div class="stat-value">${availableBooks}</div>
            <div class="stat-label">Available Books</div>
          </div>
        </div>
        <div class="stat-card info">
          <div class="stat-icon">👥</div>
          <div>
            <div class="stat-value">${totalStudents}</div>
            <div class="stat-label">Active Students</div>
          </div>
        </div>
        <div class="stat-card danger">
          <div class="stat-icon">⚠️</div>
          <div>
            <div class="stat-value">${overdueIssues}</div>
            <div class="stat-label">Overdue Books</div>
          </div>
        </div>
      </div>

      <div class="grid grid-2 mb-3">
        <div class="stat-card">
          <div class="stat-icon">📤</div>
          <div>
            <div class="stat-value">${activeIssues}</div>
            <div class="stat-label">Books Currently Issued</div>
          </div>
        </div>
        <div class="stat-card gold">
          <div class="stat-icon">💰</div>
          <div>
            <div class="stat-value">₱<fmt:formatNumber value="${totalFines}" pattern="#,##0.00"/></div>
            <div class="stat-label">Unpaid Fines</div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="card mb-3">
        <div class="card-header"><h3>⚡ Quick Actions</h3></div>
        <div class="card-body">
          <div class="d-flex gap-2" style="flex-wrap:wrap">
            <a href="${pageContext.request.contextPath}/admin/issue-book" class="btn btn-primary">📤 Issue Book</a>
            <a href="${pageContext.request.contextPath}/admin/return-book" class="btn btn-gold">📥 Return Book</a>
            <a href="${pageContext.request.contextPath}/admin/books?action=add" class="btn btn-outline">➕ Add Book</a>
            <a href="${pageContext.request.contextPath}/admin/students" class="btn btn-outline">👥 View Students</a>
            <a href="${pageContext.request.contextPath}/admin/analytics" class="btn btn-outline">📊 Analytics</a>
            <a href="${pageContext.request.contextPath}/admin/reminders" class="btn btn-danger">📧 Send Reminders</a>
          </div>
        </div>
      </div>

      <div class="grid grid-2">
        <!-- Active Issues -->
        <div class="card">
          <div class="card-header">
            <h3>📤 Currently Issued Books</h3>
            <a href="${pageContext.request.contextPath}/admin/return-book" class="btn btn-sm" style="background:rgba(255,255,255,0.2);color:#fff">View All</a>
          </div>
          <div class="card-body" style="padding:0">
            <div class="table-wrapper">
              <table>
                <thead>
                  <tr><th>Student</th><th>Book</th><th>Due Date</th><th>Status</th></tr>
                </thead>
                <tbody>
                  <c:forEach var="issue" items="${recentIssues}" end="7">
                    <tr>
                      <td>${issue.studentName}<br><small class="text-muted">${issue.studentIdCode}</small></td>
                      <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${issue.bookTitle}</td>
                      <td>
                        <fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${issue.status eq 'overdue'}">
                            <span class="badge badge-danger">Overdue</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-success">Active</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty recentIssues}">
                    <tr><td colspan="4" class="text-center text-muted" style="padding:20px">No active issues</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Most Borrowed -->
        <div class="card">
          <div class="card-header">
            <h3>🏆 Most Borrowed Books</h3>
            <a href="${pageContext.request.contextPath}/admin/analytics" class="btn btn-sm" style="background:rgba(255,255,255,0.2);color:#fff">Analytics</a>
          </div>
          <div class="card-body" style="padding:0">
            <div class="table-wrapper">
              <table>
                <thead>
                  <tr><th>#</th><th>Title</th><th>Author</th><th>Available</th></tr>
                </thead>
                <tbody>
                  <c:forEach var="book" items="${mostBorrowed}" varStatus="s">
                    <tr>
                      <td><span class="badge badge-gold">${s.index + 1}</span></td>
                      <td style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${book.title}</td>
                      <td>${book.authorName}</td>
                      <td>
                        <c:choose>
                          <c:when test="${book.availableCopies gt 0}">
                            <span class="badge badge-success">${book.availableCopies}/${book.totalCopies}</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-danger">0/${book.totalCopies}</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty mostBorrowed}">
                    <tr><td colspan="4" class="text-center text-muted" style="padding:20px">No data yet</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
