<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Students - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">👥 Manage Students</span>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <!-- Search -->
      <form method="get" action="${pageContext.request.contextPath}/admin/students" class="search-bar">
        <div class="search-input-wrap">
          <span class="search-icon">🔍</span>
          <input type="text" name="q" class="form-control"
                 placeholder="Search by name, student ID, or email..."
                 value="${searchQuery}">
        </div>
        <button type="submit" class="btn btn-primary">Search</button>
        <c:if test="${not empty searchQuery}">
          <a href="${pageContext.request.contextPath}/admin/students" class="btn btn-outline">Clear</a>
        </c:if>
      </form>

      <div class="card">
        <div class="card-header"><h3>👥 Students (${students.size()})</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Photo</th><th>Student ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Registered</th><th>Status</th><th>Actions</th></tr>
              </thead>
              <tbody>
                <c:forEach var="s" items="${students}" varStatus="st">
                  <tr>
                    <td>${st.index+1}</td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty s.profilePicture}">
                          <img src="${pageContext.request.contextPath}/uploads/profiles/${s.profilePicture}" 
                               alt="${s.fullName}" 
                               style="width:40px;height:40px;border-radius:50%;object-fit:cover;border:2px solid var(--cream-dark)">
                        </c:when>
                        <c:otherwise>
                          <div style="width:40px;height:40px;border-radius:50%;background:var(--cream-dark);display:flex;align-items:center;justify-content:center;font-size:0.9rem;font-weight:700;color:var(--navy-dark)">
                            ${s.firstName.substring(0,1)}${s.lastName.substring(0,1)}
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td><code>${s.studentId}</code></td>
                    <td><strong>${s.fullName}</strong></td>
                    <td>${s.email}</td>
                    <td>${s.phone}</td>
                    <td><fmt:formatDate value="${s.createdAt}" pattern="MMM dd, yyyy"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${s.active}"><span class="badge badge-success">Active</span></c:when>
                        <c:otherwise><span class="badge badge-danger">Inactive</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="d-flex gap-1">
                        <a href="${pageContext.request.contextPath}/admin/students?action=view&id=${s.id}"
                           class="btn btn-sm btn-outline">👁️ View</a>
                        <a href="${pageContext.request.contextPath}/admin/issue-book?studentId=${s.studentId}"
                           class="btn btn-sm btn-primary">📤 Issue</a>
                        <button class="btn btn-sm ${s.active ? 'btn-danger' : 'btn-gold'}"
                                onclick="confirmDelete('${pageContext.request.contextPath}/admin/students?action=toggle&id=${s.id}',
                                  '${s.active ? 'Deactivate' : 'Activate'} student: ${s.fullName}?')">
                          ${s.active ? '🚫' : '✅'}
                        </button>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty students}">
                  <tr><td colspan="9" class="text-center text-muted" style="padding:30px">No students found.</td></tr>
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
