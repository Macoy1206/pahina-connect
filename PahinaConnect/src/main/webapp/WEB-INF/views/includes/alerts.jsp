<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Traditional Alerts (with auto-dismiss) -->
<c:if test="${not empty error}">
  <div class="alert alert-danger" data-auto-dismiss>⚠️ ${error}</div>
</c:if>
<c:if test="${not empty success}">
  <div class="alert alert-success" data-auto-dismiss>✅ ${success}</div>
</c:if>

<!-- SweetAlert2 Toast Notifications -->
<c:if test="${not empty error}">
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      pcToast('${error}', 'error');
    });
  </script>
</c:if>

<c:if test="${not empty success}">
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      pcToast('${success}', 'success');
    });
  </script>
</c:if>

<c:if test="${not empty param.success}">
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      <c:choose>
        <c:when test="${param.success eq 'added'}">
          pcToast('✅ Record added successfully!', 'success');
        </c:when>
        <c:when test="${param.success eq 'updated'}">
          pcToast('✅ Record updated successfully!', 'success');
        </c:when>
        <c:when test="${param.success eq 'deleted'}">
          pcToast('🗑️ Record deleted successfully!', 'success');
        </c:when>
        <c:when test="${param.success eq 'issued'}">
          pcToast('📤 Book issued successfully!', 'success');
        </c:when>
        <c:when test="${param.success eq 'returned'}">
          pcToast('📥 Book returned successfully!', 'success');
        </c:when>
        <c:when test="${param.success eq 'registered'}">
          pcToast('🎉 Registration successful! Please login.', 'success');
        </c:when>
        <c:when test="${param.success eq 'password-changed'}">
          pcToast('🔐 Password changed successfully!', 'success');
        </c:when>
        <c:when test="${param.success eq 'profile-updated'}">
          pcToast('👤 Profile updated successfully!', 'success');
        </c:when>
      </c:choose>
    });
  </script>
</c:if>
