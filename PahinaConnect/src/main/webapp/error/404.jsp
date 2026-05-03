<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>404 - Page Not Found</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:var(--cream)">
  <div style="text-align:center;padding:40px">
    <div style="font-size:5rem">📚</div>
    <h1 style="font-size:4rem;color:var(--green);margin:10px 0">404</h1>
    <h2 style="color:var(--green-dark)">Page Not Found</h2>
    <p style="color:var(--text-light);margin:12px 0 24px">The page you're looking for doesn't exist or has been moved.</p>
    <a href="${pageContext.request.contextPath}/" class="btn btn-primary">🏠 Go Home</a>
  </div>
</div>
</body>
</html>
