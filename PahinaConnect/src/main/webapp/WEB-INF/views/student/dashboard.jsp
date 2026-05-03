<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>My Dashboard - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/student-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">🏠 My Dashboard</span>
      <a href="${pageContext.request.contextPath}/search" class="btn btn-primary btn-sm">🔍 Search Books</a>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <div style="background:linear-gradient(135deg,var(--navy-dark),var(--navy));border-radius:var(--radius);padding:24px;margin-bottom:24px;color:var(--cream);display:flex;align-items:center;gap:20px">
        <div style="flex-shrink:0">
          <c:choose>
            <c:when test="${not empty sessionScope.loggedUser.profilePicture}">
              <img src="${pageContext.request.contextPath}/uploads/profiles/${sessionScope.loggedUser.profilePicture}" 
                   alt="Profile" 
                   style="width:80px;height:80px;border-radius:50%;object-fit:cover;border:3px solid var(--gold)">
            </c:when>
            <c:otherwise>
              <div style="width:80px;height:80px;border-radius:50%;background:var(--gold);display:flex;align-items:center;justify-content:center;font-size:2rem;font-weight:700;color:var(--navy-dark)">
                ${sessionScope.loggedUser.firstName.substring(0,1)}${sessionScope.loggedUser.lastName.substring(0,1)}
              </div>
            </c:otherwise>
          </c:choose>
        </div>
        <div style="flex:1">
          <h2 style="color:var(--cream);margin:0">Welcome back, ${sessionScope.loggedUser.firstName}! 👋</h2>
          <p style="color:rgba(248,244,238,0.8);margin:6px 0 0">Your Student ID: <strong>${sessionScope.loggedUser.studentId}</strong></p>
        </div>
      </div>

      <!-- Stats -->
      <div class="grid grid-3 mb-3">
        <div class="stat-card">
          <div class="stat-icon">📚</div>
          <div>
            <div class="stat-value">${activeIssues.size()}</div>
            <div class="stat-label">Books Borrowed</div>
          </div>
        </div>
        <div class="stat-card gold">
          <div class="stat-icon">📖</div>
          <div>
            <div class="stat-value">${allIssues.size()}</div>
            <div class="stat-label">Total Borrowed</div>
          </div>
        </div>
        <div class="stat-card danger">
          <div class="stat-icon">⏰</div>
          <div>
            <div class="stat-value">
              <c:set var="overdueCount" value="0"/>
              <c:forEach var="i" items="${activeIssues}">
                <c:if test="${i.status eq 'overdue'}"><c:set var="overdueCount" value="${overdueCount+1}"/></c:if>
              </c:forEach>
              ${overdueCount}
            </div>
            <div class="stat-label">Overdue</div>
          </div>
        </div>
      </div>

      <div class="grid grid-2">
        <!-- Currently Borrowed -->
        <div class="card">
          <div class="card-header">
            <h3>📚 Currently Borrowed</h3>
            <a href="${pageContext.request.contextPath}/student/my-books" class="btn btn-sm" style="background:rgba(255,255,255,0.2);color:#fff">View All</a>
          </div>
          <div class="card-body" style="padding:0">
            <div class="table-wrapper">
              <table>
                <thead><tr><th>Book</th><th>Due Date</th><th>Status</th></tr></thead>
                <tbody>
                  <c:forEach var="issue" items="${activeIssues}">
                    <tr>
                      <td>${issue.bookTitle}</td>
                      <td><fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${issue.status eq 'overdue'}">
                            <span class="badge badge-danger">Overdue</span>
                          </c:when>
                          <c:otherwise><span class="badge badge-success">Active</span></c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty activeIssues}">
                    <tr><td colspan="3" class="text-center text-muted" style="padding:20px">No books currently borrowed.</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Reservations -->
        <div class="card">
          <div class="card-header"><h3>🔖 My Reservations</h3></div>
          <div class="card-body" style="padding:0">
            <div class="table-wrapper">
              <table>
                <thead><tr><th>Book</th><th>Queue</th><th>Status</th></tr></thead>
                <tbody>
                  <c:forEach var="r" items="${reservations}">
                    <tr>
                      <td>${r.bookTitle}</td>
                      <td>#${r.queuePosition}</td>
                      <td>
                        <c:choose>
                          <c:when test="${r.status eq 'pending'}"><span class="badge badge-warning">Pending</span></c:when>
                          <c:when test="${r.status eq 'fulfilled'}"><span class="badge badge-success">Fulfilled</span></c:when>
                          <c:otherwise><span class="badge badge-danger">${r.status}</span></c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty reservations}">
                    <tr><td colspan="3" class="text-center text-muted" style="padding:20px">No reservations.</td></tr>
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
