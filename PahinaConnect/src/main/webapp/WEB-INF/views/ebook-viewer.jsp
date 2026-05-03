<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title><c:out value="${book.title}"/> - E-Book Reader</title>
  <%@ include file="includes/head.jsp" %>
  <style>
    .reader-controls {
      position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
      background: rgba(27,58,107,0.97); backdrop-filter: blur(10px);
      padding: 10px 20px; display: flex; align-items: center; justify-content: space-between;
      box-shadow: 0 2px 12px rgba(0,0,0,0.3);
    }
    .reader-controls .book-info { color: #F8F4EE; font-size: 0.9rem; font-weight: 600; }
    .reader-controls .book-info small { color: #C8A96E; display: block; font-size: 0.75rem; font-weight: 400; }
    .reader-btn { background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25); color: #F8F4EE; padding: 6px 14px; border-radius: 6px; cursor: pointer; font-size: 0.82rem; text-decoration: none; transition: all 0.2s; display: inline-flex; align-items: center; gap: 4px; }
    .reader-btn:hover { background: rgba(200,169,110,0.4); color: #fff; text-decoration: none; }
    .reader-btn.gold { background: #C8A96E; border-color: #C8A96E; color: #fff; }
    .reader-btn.gold:hover { background: #b8996e; }
    .font-controls { display: flex; align-items: center; gap: 8px; }
    .font-btn { background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25); color: #F8F4EE; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; font-size: 1rem; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
    .font-btn:hover { background: rgba(200,169,110,0.4); }
    #reader-frame { width: 100%; border: none; display: block; }
    body { margin: 0; padding: 0; background: #1a1a2e; overflow: hidden; }
    .d-flex { display: flex; }
    .align-center { align-items: center; }
    .gap-2 { gap: 12px; }
  </style>
</head>
<body>
  <div class="reader-controls">
    <div class="d-flex align-center gap-2">
      <a href="javascript:history.back()" class="reader-btn">&#8592; Back</a>
      <div class="book-info">
        <span><c:out value="${book.title}"/></span>
        <small>by <c:out value="${book.authorName}"/></small>
      </div>
    </div>
    <div class="d-flex align-center gap-2">
      <div class="font-controls">
        <button class="font-btn" onclick="changeFontSize(-1)" title="Decrease font size">A-</button>
        <button class="font-btn" onclick="changeFontSize(1)" title="Increase font size">A+</button>
        <button class="font-btn" onclick="toggleDark()" title="Toggle dark mode" id="darkBtn">&#127769;</button>
      </div>
      <a href="${pageContext.request.contextPath}/ebook?action=download&bookId=${book.id}" class="reader-btn gold">&#11015; Download</a>
    </div>
  </div>

  <c:if test="${not empty error}">
    <div style="margin-top:70px;padding:20px;color:#fff;text-align:center;">
      <p>${error}</p>
      <a href="javascript:history.back()" class="reader-btn">&#8592; Go Back</a>
    </div>
  </c:if>

  <c:if test="${not empty book}">
    <iframe id="reader-frame"
            src="${pageContext.request.contextPath}/uploads/ebooks/${book.ebookFile}"
            style="height:calc(100vh - 60px);width:100%;border:none;margin-top:60px"
            title="${book.title}">
    </iframe>
  </c:if>

<script>
var fontSize = 18;
var dark = false;

function changeFontSize(delta) {
  fontSize = Math.min(28, Math.max(14, fontSize + delta));
  var frame = document.getElementById('reader-frame');
  if (!frame) return;
  try {
    var doc = frame.contentDocument || frame.contentWindow.document;
    if (doc && doc.body) {
      doc.body.style.fontSize = fontSize + 'px';
    }
  } catch(e) { /* cross-origin guard */ }
  localStorage.setItem('readerFontSize', fontSize);
}

function toggleDark() {
  dark = !dark;
  var frame = document.getElementById('reader-frame');
  var btn = document.getElementById('darkBtn');
  if (!frame) return;
  try {
    var doc = frame.contentDocument || frame.contentWindow.document;
    if (doc && doc.body) {
      if (dark) {
        doc.body.style.background = '#1a1a2e';
        doc.body.style.color = '#e0e0e0';
        document.body.style.background = '#1a1a2e';
        if (btn) btn.textContent = '\u2600\uFE0F';
      } else {
        doc.body.style.background = '#faf8f5';
        doc.body.style.color = '#2c2c2c';
        document.body.style.background = '#1a1a2e';
        if (btn) btn.textContent = '\uD83C\uDF19';
      }
    }
  } catch(e) { /* cross-origin guard */ }
}

window.onload = function() {
  var saved = localStorage.getItem('readerFontSize');
  if (saved) {
    fontSize = parseInt(saved, 10);
    var frame = document.getElementById('reader-frame');
    if (frame) {
      frame.onload = function() {
        try {
          var doc = frame.contentDocument || frame.contentWindow.document;
          if (doc && doc.body) {
            doc.body.style.fontSize = fontSize + 'px';
          }
        } catch(e) {}
      };
    }
  }
};
</script>
</body>
</html>
