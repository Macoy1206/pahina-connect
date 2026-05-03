<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Login - Pahina Connect</title>
  <%@ include file="includes/head.jsp" %>
</head>
<body style="overflow:hidden;height:100vh;">
<div class="auth-page">
  <div class="auth-card">
    <div class="auth-header">
      <span class="logo-icon">📚</span>
      <h1>Pahina Connect</h1>
      <p>Library Management System</p>
    </div>
    <div class="auth-body">
      <h2 style="margin-bottom:20px;font-size:1.1rem;color:var(--navy-dark);text-align:center;font-weight:700">
        Welcome Back
      </h2>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ ${error}</div>
      </c:if>
      <c:if test="${not empty success}">
        <div class="alert alert-success">✅ ${success}</div>
      </c:if>
      <c:if test="${param.msg eq 'loggedout'}">
        <div class="alert alert-info">You have been logged out successfully.</div>
      </c:if>

      <form method="post" action="${pageContext.request.contextPath}/login" novalidate id="loginForm">
        <div class="form-group">
          <label class="form-label" for="email">Email Address <span class="required">*</span></label>
          <input type="email" id="email" name="email" class="form-control"
                 placeholder="Enter your email" required value="${param.email}"
                 style="width:100%;box-sizing:border-box">
        </div>
        <div class="form-group">
          <label class="form-label" for="password">Password <span class="required">*</span></label>
          <input type="password" id="password" name="password" class="form-control"
                 placeholder="Enter your password" required
                 style="width:100%;box-sizing:border-box">
        </div>
        <div style="text-align:right;margin-bottom:18px">
          <a href="${pageContext.request.contextPath}/forgot-password"
             style="font-size:0.85rem;color:var(--navy)">Forgot Password?</a>
        </div>
        <button type="submit" class="btn btn-primary btn-block btn-lg">
          🔑 Login
        </button>
      </form>
    </div>
    <div class="auth-footer">
      Don't have an account?
      <a href="${pageContext.request.contextPath}/register"
         style="color:var(--navy);font-weight:600">Register here</a>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
// Show SweetAlert on successful registration
<c:if test="${param.registered eq 'true'}">
  document.addEventListener('DOMContentLoaded', function() {
    Swal.fire({
      icon: 'success',
      title: '🎉 Registration Successful!',
      html: 'Your account has been created.<br>Please login to continue.',
      confirmButtonText: 'Login Now',
      allowOutsideClick: false
    });
  });
</c:if>

// Show SweetAlert on password reset
<c:if test="${param.reset eq 'success'}">
  document.addEventListener('DOMContentLoaded', function() {
    Swal.fire({
      icon: 'success',
      title: '🔐 Password Reset Successful!',
      html: 'Your password has been reset.<br>Please login with your new password.',
      confirmButtonText: 'Login Now'
    });
  });
</c:if>
</script>
</body>
</html>
