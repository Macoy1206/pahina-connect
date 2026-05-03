<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>SweetAlert Demo - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">🎨 SweetAlert2 Demo</span>
    </div>
    <div class="page-content">
      
      <div class="welcome-banner">
        <h2>🎉 SweetAlert2 Implementation</h2>
        <p>Test all the beautiful confirmation dialogs and alerts in Pahina Connect</p>
      </div>

      <!-- Basic Alerts -->
      <div class="card mb-3">
        <div class="card-header"><h3>✨ Basic Alerts</h3></div>
        <div class="card-body">
          <div class="d-flex gap-2" style="flex-wrap:wrap">
            <button class="btn btn-primary" onclick="testSuccess()">✅ Success Alert</button>
            <button class="btn btn-danger" onclick="testError()">❌ Error Alert</button>
            <button class="btn btn-gold" onclick="testWarning()">⚠️ Warning Alert</button>
            <button class="btn btn-outline" onclick="testInfo()">ℹ️ Info Alert</button>
          </div>
        </div>
      </div>

      <!-- Confirmation Dialogs -->
      <div class="card mb-3">
        <div class="card-header"><h3>❓ Confirmation Dialogs</h3></div>
        <div class="card-body">
          <div class="d-flex gap-2" style="flex-wrap:wrap">
            <button class="btn btn-primary" onclick="testConfirmPrimary()">🔵 Primary Confirm</button>
            <button class="btn btn-gold" onclick="testConfirmGold()">🟡 Gold Confirm</button>
            <button class="btn btn-danger" onclick="testConfirmDanger()">🔴 Danger Confirm</button>
            <button class="btn btn-outline" onclick="testConfirmQuestion()">❓ Question Confirm</button>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div class="card mb-3">
        <div class="card-header"><h3>🍞 Toast Notifications</h3></div>
        <div class="card-body">
          <div class="d-flex gap-2" style="flex-wrap:wrap">
            <button class="btn btn-primary" onclick="testToastSuccess()">✅ Success Toast</button>
            <button class="btn btn-danger" onclick="testToastError()">❌ Error Toast</button>
            <button class="btn btn-gold" onclick="testToastWarning()">⚠️ Warning Toast</button>
            <button class="btn btn-outline" onclick="testToastInfo()">ℹ️ Info Toast</button>
          </div>
        </div>
      </div>

      <!-- Special Dialogs -->
      <div class="card mb-3">
        <div class="card-header"><h3>🎯 Special Dialogs</h3></div>
        <div class="card-body">
          <div class="d-flex gap-2" style="flex-wrap:wrap">
            <button class="btn btn-primary" onclick="testLoading()">⏳ Loading Dialog</button>
            <button class="btn btn-gold" onclick="testTimer()">⏱️ Auto-Close Timer</button>
            <button class="btn btn-outline" onclick="testHTML()">📝 HTML Content</button>
            <button class="btn btn-danger" onclick="testDeleteConfirm()">🗑️ Delete Confirm</button>
          </div>
        </div>
      </div>

      <!-- Real-World Examples -->
      <div class="card">
        <div class="card-header"><h3>🌍 Real-World Examples</h3></div>
        <div class="card-body">
          <div class="d-flex gap-2" style="flex-wrap:wrap">
            <button class="btn btn-primary" onclick="testIssueBook()">📤 Issue Book</button>
            <button class="btn btn-gold" onclick="testReturnBook()">📥 Return Book (with Fine)</button>
            <button class="btn btn-outline" onclick="testPasswordChange()">🔒 Change Password</button>
            <button class="btn btn-danger" onclick="testRegistration()">📝 Registration</button>
          </div>
        </div>
      </div>

    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
// Basic Alerts
function testSuccess() {
  pcAlert('Success!', 'Your operation completed successfully.', 'success');
}

function testError() {
  pcAlert('Error!', 'Something went wrong. Please try again.', 'error');
}

function testWarning() {
  pcAlert('Warning!', 'Please review your input before proceeding.', 'warning');
}

function testInfo() {
  pcAlert('Information', 'This is an informational message.', 'info');
}

// Confirmation Dialogs
function testConfirmPrimary() {
  pcConfirm({
    type: 'info',
    title: 'Primary Confirmation',
    message: 'Do you want to proceed with this action?',
    confirmText: 'Yes, Continue',
    cancelText: 'Cancel'
  }).then(function(confirmed) {
    if (confirmed) {
      pcToast('✅ Action confirmed!', 'success');
    } else {
      pcToast('❌ Action cancelled', 'error');
    }
  });
}

function testConfirmGold() {
  Swal.fire({
    icon: 'question',
    title: 'Gold Confirmation',
    text: 'This uses the gold accent color.',
    showCancelButton: true,
    confirmButtonText: 'Proceed',
    cancelButtonText: 'Cancel',
    reverseButtons: true,
    customClass: {
      confirmButton: 'swal2-gold'
    }
  }).then(function(result) {
    if (result.isConfirmed) {
      pcToast('✅ Gold action confirmed!', 'success');
    }
  });
}

function testConfirmDanger() {
  pcConfirm({
    type: 'danger',
    title: 'Danger Confirmation',
    message: 'This action is destructive and cannot be undone!',
    confirmText: 'Yes, Delete',
    cancelText: 'Cancel'
  }).then(function(confirmed) {
    if (confirmed) {
      pcToast('🗑️ Item deleted!', 'success');
    }
  });
}

function testConfirmQuestion() {
  Swal.fire({
    icon: 'question',
    title: 'Are you sure?',
    text: 'This is a standard question dialog.',
    showCancelButton: true,
    confirmButtonText: 'Yes',
    cancelButtonText: 'No',
    reverseButtons: true
  });
}

// Toast Notifications
function testToastSuccess() {
  pcToast('✅ Operation completed successfully!', 'success');
}

function testToastError() {
  pcToast('❌ An error occurred!', 'error');
}

function testToastWarning() {
  pcToast('⚠️ Please check your input!', 'warning');
}

function testToastInfo() {
  pcToast('ℹ️ Here is some information', 'info');
}

// Special Dialogs
function testLoading() {
  Swal.fire({
    title: 'Processing...',
    html: 'Please wait while we process your request.',
    allowOutsideClick: false,
    allowEscapeKey: false,
    didOpen: function() {
      Swal.showLoading();
    }
  });
  
  // Auto close after 3 seconds
  setTimeout(function() {
    Swal.close();
    pcToast('✅ Processing complete!', 'success');
  }, 3000);
}

function testTimer() {
  let timerInterval;
  Swal.fire({
    icon: 'info',
    title: 'Auto-Close Timer',
    html: 'This dialog will close in <b></b> seconds.',
    timer: 5000,
    timerProgressBar: true,
    didOpen: () => {
      const b = Swal.getHtmlContainer().querySelector('b');
      timerInterval = setInterval(() => {
        b.textContent = Math.ceil(Swal.getTimerLeft() / 1000);
      }, 100);
    },
    willClose: () => {
      clearInterval(timerInterval);
    }
  });
}

function testHTML() {
  Swal.fire({
    icon: 'info',
    title: 'HTML Content',
    html: '<div style="text-align:left;padding:10px">' +
          '<p><strong>Student:</strong> Juan Dela Cruz</p>' +
          '<p><strong>Student ID:</strong> STU0001234</p>' +
          '<p><strong>Email:</strong> juan@example.com</p>' +
          '<hr style="margin:10px 0">' +
          '<p style="color:#1E6B3C">✅ All information verified</p>' +
          '</div>',
    confirmButtonText: 'OK'
  });
}

function testDeleteConfirm() {
  confirmDelete('#', 'Are you sure you want to delete this item? This action cannot be undone.');
}

// Real-World Examples
function testIssueBook() {
  var dueDate = new Date();
  dueDate.setDate(dueDate.getDate() + 14);
  var dueDateStr = dueDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  
  Swal.fire({
    icon: 'question',
    title: '📤 Confirm Book Issue',
    html: '<div style="text-align:left;padding:10px">' +
          '<p><strong>Student:</strong> Juan Dela Cruz</p>' +
          '<p><strong>Student ID:</strong> STU0001234</p>' +
          '<p><strong>Book:</strong> The Great Gatsby</p>' +
          '<p><strong>Loan Duration:</strong> 14 days</p>' +
          '<p><strong>Due Date:</strong> ' + dueDateStr + '</p>' +
          '</div>',
    showCancelButton: true,
    confirmButtonText: 'Yes, Issue Book',
    cancelButtonText: 'Cancel',
    reverseButtons: true,
    customClass: {
      confirmButton: 'swal2-gold'
    }
  }).then(function(result) {
    if (result.isConfirmed) {
      Swal.fire({
        title: 'Processing...',
        html: 'Issuing book to student...',
        allowOutsideClick: false,
        didOpen: function() {
          Swal.showLoading();
        }
      });
      setTimeout(function() {
        Swal.close();
        pcToast('📤 Book issued successfully!', 'success');
      }, 2000);
    }
  });
}

function testReturnBook() {
  var fine = 150.00;
  var daysOverdue = 5;
  
  Swal.fire({
    icon: 'warning',
    title: '📥 Confirm Book Return',
    html: '<div style="text-align:left;padding:10px">' +
          '<p><strong>Student:</strong> Maria Santos</p>' +
          '<p><strong>Book:</strong> To Kill a Mockingbird</p>' +
          '<p style="color:#C0392B;font-size:1.1rem;margin-top:10px"><strong>⚠️ Fine Amount: ₱' + fine.toFixed(2) + '</strong></p>' +
          '<p style="color:#7A8FA8;font-size:0.9rem">(' + daysOverdue + ' days overdue @ ₱30/day)</p>' +
          '<div style="margin-top:15px;padding:12px;background:#FEF8E7;border-left:3px solid #B7770D;border-radius:4px">' +
          '<p style="margin:0;font-size:0.85rem;color:#B7770D">⚠️ Please collect the fine before processing return.</p>' +
          '</div>' +
          '</div>',
    showCancelButton: true,
    confirmButtonText: 'Return & Collect Fine',
    cancelButtonText: 'Cancel',
    reverseButtons: true,
    customClass: {
      confirmButton: 'swal2-gold'
    },
    focusCancel: true
  }).then(function(result) {
    if (result.isConfirmed) {
      pcToast('📥 Book returned! Fine: ₱' + fine.toFixed(2), 'success');
    }
  });
}

function testPasswordChange() {
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
        didOpen: function() {
          Swal.showLoading();
        }
      });
      setTimeout(function() {
        Swal.close();
        pcToast('🔐 Password changed successfully!', 'success');
      }, 2000);
    }
  });
}

function testRegistration() {
  Swal.fire({
    icon: 'question',
    title: '📝 Confirm Registration',
    html: 'Are you sure all information is correct?<br><small class="text-muted">You can update your profile later.</small>',
    showCancelButton: true,
    confirmButtonText: 'Yes, Register',
    cancelButtonText: 'Review Again',
    reverseButtons: true
  }).then(function(result) {
    if (result.isConfirmed) {
      Swal.fire({
        title: 'Creating Account...',
        html: 'Please wait while we process your registration.',
        allowOutsideClick: false,
        didOpen: function() {
          Swal.showLoading();
        }
      });
      setTimeout(function() {
        Swal.fire({
          icon: 'success',
          title: '🎉 Registration Successful!',
          html: 'Your account has been created.<br>Please login to continue.',
          confirmButtonText: 'Login Now'
        });
      }, 2000);
    }
  });
}
</script>
</body>
</html>
