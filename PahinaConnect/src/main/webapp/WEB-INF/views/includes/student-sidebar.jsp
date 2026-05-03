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
    <a class="nav-link" href="${pageContext.request.contextPath}/student/dashboard">
      <span class="nav-icon">🏠</span> Dashboard
    </a>
    <span class="nav-section-title">Library</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/search">
      <span class="nav-icon">🔍</span> Search Books
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/student/my-books">
      <span class="nav-icon">📚</span> My Books
    </a>
    <span class="nav-section-title">Account</span>
    <a class="nav-link" href="${pageContext.request.contextPath}/student/profile">
      <span class="nav-icon">👤</span> My Profile
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/student/change-password">
      <span class="nav-icon">🔒</span> Change Password
    </a>
    <a class="nav-link" href="${pageContext.request.contextPath}/logout"
       data-confirm="You will be signed out of your account."
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
        <div class="user-role">${user.studentId}</div>
      </div>
    </div>
  </div>
</aside>
