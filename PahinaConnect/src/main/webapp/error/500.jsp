<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>500 - Server Error</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:var(--cream)">
  <div style="text-align:center;padding:40px">
    <div style="font-size:5rem">⚠️</div>
    <h1 style="font-size:4rem;color:var(--danger);margin:10px 0">500</h1>
    <h2 style="color:var(--green-dark)">Internal Server Error</h2>
    <p style="color:var(--text-light);margin:12px 0 24px">Something went wrong on our end. Please try again later.</p>
    <a href="${pageContext.request.contextPath}/" class="btn btn-primary">🏠 Go Home</a>
  </div>
</div>
</body>
</html>
