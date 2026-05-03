<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="user" value="${sessionScope.loggedUser}" />
<aside class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    <span class="brand-icon">📚</span>
    <h2>Pahina Connect</h2>
    <p>Library Management System</p>
  </div>
  <nav class="sidebar-nav">
    <span class="nav-section-title">Main</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">
      <span class="nav-icon">🏠</span> Dashboard
    </a>
    <span class="nav-section-title">Books</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/books">
      <span class="nav-icon">📖</span> Manage Books
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/categories">
      <span class="nav-icon">🗂️</span> Categories
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/authors">
      <span class="nav-icon">✍️</span> Authors
    </a>
    <span class="nav-section-title">Circulation</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/borrow-requests">
      <span class="nav-icon">📥</span> Borrow Requests
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/issue-book">
      <span class="nav-icon">📤</span> Issue Book
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/return-book">
      <span class="nav-icon">📥</span> Return Book
    </a>
    <span class="nav-section-title">Students</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/students">
      <span class="nav-icon">👥</span> Manage Students
    </a>
    <span class="nav-section-title">Reports</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/analytics">
      <span class="nav-icon">📊</span> Analytics
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/reminders">
      <span class="nav-icon">📧</span> Email Reminders
    </a>
    <span class="nav-section-title">Search</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/search">
      <span class="nav-icon">🔍</span> Advanced Search
    </a>
    <span class="nav-section-title">Account</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/admin/change-password">
      <span class="nav-icon">🔒</span> Change Password
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/logout"
       data-confirm="You will be signed out of the admin panel."
       data-confirm-title="Log Out?"
       data-confirm-type="info"
       data-confirm-icon="🚪"
       data-confirm-ok="Yes, Log Out"
       data-confirm-cancel="Stay">
      <span class="nav-icon">🚪</span> Logout
    </a>
  </nav>
  <div class="sidebar-footer">
    <div class="user-info">
      <div class="user-avatar">
        <c:choose>
          <c:when test="${not empty user.profilePicture}">
            <img src="${pageContext.request.contextPath}/uploads/profiles/${user.profilePicture}" 
                 alt="${user.firstName}" 
                 style="width:100%;height:100%;border-radius:50%;object-fit:cover">
          </c:when>
          <c:otherwise>👤</c:otherwise>
        </c:choose>
      </div>
      <div class="user-details">
        <div class="user-name">${user.firstName} ${user.lastName}</div>
        <div class="user-role">Administrator</div>
      </div>
    </div>
  </div>
</aside>
