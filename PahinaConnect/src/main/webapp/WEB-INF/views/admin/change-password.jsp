<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Change Password - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar"><span class="topbar-title">🔒 Change Password</span></div>
    <div class="page-content-centered">
      <%@ include file="../includes/alerts.jsp" %>
      <div class="form-card">
        <div class="form-card-header">
          <h3>🔒 Update Your Password</h3>
          <p>Choose a strong password to keep your account secure</p>
        </div>
        <div class="form-card-body">
          <form method="post" action="${pageContext.request.contextPath}/admin/change-password" id="changePasswordForm">
            <div class="form-group">
              <label class="form-label">Current Password <span class="required">*</span></label>
              <input type="password" name="currentPassword" class="form-control"
                     required placeholder="Enter your current password">
            </div>
            <div class="section-divider">New Password</div>
            <div class="form-group">
              <label class="form-label">New Password <span class="required">*</span></label>
              <input type="password" name="newPassword" id="newPassword" class="form-control"
                     required placeholder="Min. 8 chars with uppercase, number, special char"
                     data-strength="pwdStrength">
              <div id="pwdStrength" class="password-strength"></div>
            </div>
            <div class="form-group">
              <label class="form-label">Confirm New Password <span class="required">*</span></label>
              <input type="password" name="confirmPassword" id="confirmPassword" class="form-control"
                     required placeholder="Re-enter new password">
            </div>
            <button type="submit" class="btn btn-primary btn-block">🔒 Change Password</button>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
// Change password confirmation
document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
  e.preventDefault();
  
  var newPwd = document.getElementById('newPassword').value;
  var confirmPwd = document.getElementById('confirmPassword').value;
  
  // Validate passwords match
  if (newPwd !== confirmPwd) {
    Swal.fire({
      icon: 'error',
      title: 'Password Mismatch',
      text: 'New password and confirmation do not match.',
      confirmButtonText: 'OK'
    });
    return;
  }
  
  // Validate password strength
  if (newPwd.length < 8 || !/[A-Z]/.test(newPwd) || !/[0-9]/.test(newPwd) || !/[@$!%*?&]/.test(newPwd)) {
    Swal.fire({
      icon: 'warning',
      title: 'Weak Password',
      html: 'Password must contain:<br>' +
            '• At least 8 characters<br>' +
            '• One uppercase letter<br>' +
            '• One number<br>' +
            '• One special character (@$!%*?&)',
      confirmButtonText: 'OK'
    });
    return;
  }
  
  Swal.fire({
    icon: 'question',
    title: '🔒 Confirm Password Change',
    text: 'Are you sure you want to change your password?',
    showCancelButton: true,
    confirmButtonText: 'Yes, Change Password',
    cancelButtonText: 'Cancel',
    reverseButtons: true
  }).then(function(result) {
    if (result.isConfirmed) {
      Swal.fire({
        title: 'Updating Password...',
        html: 'Please wait...',
        allowOutsideClick: false,
        allowEscapeKey: false,
        didOpen: function() {
          Swal.showLoading();
        }
      });
      e.target.submit();
    }
  });
});
</script>
</body>
</html>
