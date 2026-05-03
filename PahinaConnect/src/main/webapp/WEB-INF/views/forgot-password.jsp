<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Forgot Password - Pahina Connect</title>
  <%@ include file="includes/head.jsp" %>
</head>
<body>
<div class="auth-page">
  <div class="auth-card">
    <div class="auth-header">
      <span class="logo-icon">🔐</span>
      <h1>Pahina Connect</h1>
      <p>Password Recovery</p>
    </div>
    <div class="auth-body">
      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ ${error}</div>
      </c:if>
      <c:if test="${not empty success}">
        <div class="alert alert-success">✅ ${success}</div>
      </c:if>

      <!-- Step 1: Enter Email -->
      <c:if test="${step eq '1' or empty step}">
        <h3 style="margin-bottom:8px;font-size:1rem;color:var(--navy-dark)">Step 1 of 3 — Enter Your Email</h3>
        <p style="color:var(--text-light);font-size:0.88rem;margin-bottom:20px">
          We'll send a 6-digit OTP to your registered email.
        </p>
        <form method="post" action="${pageContext.request.contextPath}/forgot-password">
          <input type="hidden" name="action" value="sendOtp">
          <div class="form-group">
            <label class="form-label">Email Address <span class="required">*</span></label>
            <input type="email" name="email" class="form-control"
                   placeholder="Enter your registered email" required
                   style="width:100%;box-sizing:border-box">
          </div>
          <button type="submit" class="btn btn-primary btn-block">📧 Send OTP</button>
        </form>
      </c:if>

      <!-- Step 2: Enter OTP -->
      <c:if test="${step eq '2'}">
        <h3 style="margin-bottom:8px;font-size:1rem;color:var(--navy-dark)">Step 2 of 3 — Enter OTP</h3>
        <p style="color:var(--text-light);font-size:0.88rem;margin-bottom:20px">
          Enter the 6-digit OTP sent to your email. Valid for 10 minutes.
        </p>
        <form method="post" action="${pageContext.request.contextPath}/forgot-password">
          <input type="hidden" name="action" value="verifyOtp">
          <div class="form-group">
            <label class="form-label">One-Time Password <span class="required">*</span></label>
            <input type="text" name="otp" class="form-control"
                   placeholder="Enter 6-digit OTP" required maxlength="6"
                   style="font-size:1.6rem;letter-spacing:10px;text-align:center;width:100%;box-sizing:border-box">
          </div>
          <button type="submit" class="btn btn-primary btn-block">✅ Verify OTP</button>
        </form>
      </c:if>

      <!-- Step 3: New Password -->
      <c:if test="${step eq '3'}">
        <h3 style="margin-bottom:8px;font-size:1rem;color:var(--navy-dark)">Step 3 of 3 — Set New Password</h3>
        <form method="post" action="${pageContext.request.contextPath}/forgot-password">
          <input type="hidden" name="action" value="resetPassword">
          <div class="form-group">
            <label class="form-label">New Password <span class="required">*</span></label>
            <input type="password" id="newPassword" name="newPassword" class="form-control"
                   placeholder="Min. 8 chars with uppercase, number, special char"
                   required data-strength="pwdStrength"
                   style="width:100%;box-sizing:border-box">
            <div id="pwdStrength" class="password-strength"></div>
          </div>
          <div class="form-group">
            <label class="form-label">Confirm Password <span class="required">*</span></label>
            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                   placeholder="Re-enter new password" required
                   style="width:100%;box-sizing:border-box">
          </div>
          <button type="submit" class="btn btn-primary btn-block">🔒 Reset Password</button>
        </form>
      </c:if>
    </div>
    <div class="auth-footer">
      <a href="${pageContext.request.contextPath}/login" style="color:var(--navy)">← Back to Login</a>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
