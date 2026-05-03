<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>QR Scanner - Pahina Connect</title>
  <%@ include file="includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📱 QR Code Scanner</span>
      <a href="${pageContext.request.contextPath}/admin/issue-book" class="btn btn-outline btn-sm">← Back</a>
    </div>
    <div class="page-content">
      <div style="max-width:600px;margin:auto">
        <div class="card">
          <div class="card-header"><h3>📱 Scan Book QR Code</h3></div>
          <div class="card-body text-center">
            <div style="position:relative;background:#000;border-radius:var(--radius);overflow:hidden;margin-bottom:16px">
              <video id="qrVideo" style="width:100%;max-height:350px;display:block" playsinline></video>
              <canvas id="qrCanvas" style="display:none"></canvas>
              <div style="position:absolute;inset:0;border:3px solid var(--gold);border-radius:var(--radius);pointer-events:none"></div>
            </div>
            <div id="qrResult" style="margin-bottom:16px"></div>
            <div class="d-flex gap-2" style="justify-content:center">
              <button onclick="startQRScanner()" class="btn btn-primary">▶️ Start Scanner</button>
              <button onclick="stopQRScanner()" class="btn btn-outline">⏹️ Stop</button>
            </div>
            <p style="margin-top:16px;font-size:0.85rem;color:var(--text-light)">
              Point your camera at a Pahina Connect book QR code to scan it.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
