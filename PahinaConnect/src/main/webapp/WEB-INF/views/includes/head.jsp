<%@ page contentType="text/html;charset=UTF-8" %>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- Prevent browser from caching pages - back button after logout goes to login -->
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=12">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>📚</text></svg>">
<!-- SweetAlert2 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>const contextPath = '${pageContext.request.contextPath}';</script>
<script>
// Prevent back button from showing cached pages after logout
// This runs on every page load and checks if the session is still valid
(function() {
  // Push a new state so back button triggers popstate
  if (window.history && window.history.pushState) {
    window.history.pushState({ page: 'current' }, '', window.location.href);
    window.addEventListener('popstate', function() {
      // When back is pressed, reload the page from server (not cache)
      window.location.reload(true);
    });
  }
})();
</script>
