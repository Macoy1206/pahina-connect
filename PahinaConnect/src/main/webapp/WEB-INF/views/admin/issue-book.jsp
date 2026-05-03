<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Issue Book - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📤 Issue Book</span>
      <a href="${pageContext.request.contextPath}/qrcode?action=scan" class="btn btn-gold btn-sm">📱 Scan QR</a>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>
      <c:if test="${not empty searchError}">
        <div class="alert alert-warning">⚠️ ${searchError}</div>
      </c:if>

      <div class="grid grid-2">

        <!-- Step 1: Find Student -->
        <div class="card">
          <div class="card-header"><h3>👤 Step 1: Find Student</h3></div>
          <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/issue-book" id="searchStudentForm">
              <div class="form-group">
                <label class="form-label">Student ID or Name <span class="required">*</span></label>
                <div style="position:relative">
                  <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-light);pointer-events:none">🔍</span>
                  <input type="text" name="studentId" id="studentIdInput" class="form-control"
                         placeholder="Search student..."
                         value="${param.studentId}"
                         autocomplete="off"
                         style="padding-left:38px"
                         required>
                  <!-- Autocomplete dropdown -->
                  <div id="studentSuggestions"
                       style="display:none;position:absolute;top:100%;left:0;right:0;z-index:9999;
                              background:#fff;border:2px solid var(--navy);border-top:none;
                              border-radius:0 0 8px 8px;max-height:260px;overflow-y:auto;
                              box-shadow:0 8px 24px rgba(27,58,107,0.18)">
                  </div>
                </div>
                <span class="form-hint">Type student ID or name to see suggestions</span>
              </div>
              <button type="submit" class="btn btn-primary">🔍 Search</button>
            </form>

            <c:if test="${not empty student}">
              <div style="margin-top:20px;padding:16px;background:var(--cream);border-radius:var(--radius);border-left:4px solid var(--green)">
                <h4 style="color:var(--green-dark);margin-bottom:12px">✅ Student Found</h4>
                <div style="display:flex;align-items:center;gap:14px">
                  <c:choose>
                    <c:when test="${not empty student.profilePicture}">
                      <img src="${pageContext.request.contextPath}/uploads/profiles/${student.profilePicture}"
                           style="width:56px;height:56px;border-radius:50%;object-fit:cover;border:3px solid var(--green);flex-shrink:0">
                    </c:when>
                    <c:otherwise>
                      <div style="width:56px;height:56px;border-radius:50%;background:var(--green);display:flex;align-items:center;justify-content:center;font-size:1.4rem;font-weight:700;color:#fff;flex-shrink:0">
                        ${student.firstName.substring(0,1)}${student.lastName.substring(0,1)}
                      </div>
                    </c:otherwise>
                  </c:choose>
                  <div>
                    <div style="font-weight:700;font-size:1rem;color:var(--navy-dark)">${student.fullName}</div>
                    <div style="font-size:0.85rem;color:var(--text-light);margin-top:2px">
                      <code>${student.studentId}</code> &bull; ${student.email}
                    </div>
                    <div style="font-size:0.85rem;color:var(--text-light)">📞 ${student.phone}</div>
                  </div>
                </div>
              </div>
            </c:if>
          </div>
        </div>

        <!-- Step 2: Issue Book -->
        <div class="card">
          <div class="card-header"><h3>📖 Step 2: Issue Book</h3></div>
          <div class="card-body">
            <c:choose>
              <c:when test="${not empty student}">
                <form method="post" action="${pageContext.request.contextPath}/admin/issue-book" id="issueBookForm">
                  <input type="hidden" name="studentIdCode" value="${student.studentId}">
                  <div class="form-group">
                    <label class="form-label">Select Book <span class="required">*</span></label>
                    <select name="bookId" id="bookId" class="form-control" required>
                      <option value="">-- Select a Book --</option>
                      <c:forEach var="book" items="${books}">
                        <c:if test="${book.availableCopies gt 0}">
                          <option value="${book.id}">${book.title} (${book.isbn}) - ${book.availableCopies} avail</option>
                        </c:if>
                      </c:forEach>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="form-label">Loan Duration <span class="required">*</span></label>
                    <select name="dueDays" id="dueDays" class="form-control" required>
                      <option value="7">7 days (1 week)</option>
                      <option value="14" selected>14 days (2 weeks)</option>
                      <option value="21">21 days (3 weeks)</option>
                      <option value="30">30 days (1 month)</option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="form-label">Notes</label>
                    <textarea name="notes" class="form-control" rows="2" placeholder="Optional notes"></textarea>
                  </div>
                  <button type="submit" class="btn btn-primary btn-block">📤 Issue Book</button>
                </form>
              </c:when>
              <c:otherwise>
                <div class="text-center text-muted" style="padding:30px">
                  <span style="font-size:3rem">👤</span>
                  <p style="margin-top:10px">Search for a student first to issue a book.</p>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>

      <!-- Active Issues for this student -->
      <c:if test="${not empty activeIssues}">
        <div class="card mt-3">
          <div class="card-header"><h3>📚 Currently Issued to ${student.fullName}</h3></div>
          <div class="card-body" style="padding:0">
            <div class="table-wrapper">
              <table>
                <thead><tr><th>Book</th><th>Issue Date</th><th>Due Date</th><th>Status</th></tr></thead>
                <tbody>
                  <c:forEach var="issue" items="${activeIssues}">
                    <tr>
                      <td>${issue.bookTitle}</td>
                      <td><fmt:formatDate value="${issue.issueDate}" pattern="MMM dd, yyyy"/></td>
                      <td><fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${issue.status eq 'overdue'}">
                            <span class="badge badge-danger">Overdue</span>
                          </c:when>
                          <c:otherwise><span class="badge badge-success">Active</span></c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </c:if>

    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
// ── Student Autocomplete ─────────────────────────────────────────────────────
(function () {
  var input     = document.getElementById('studentIdInput');
  var dropdown  = document.getElementById('studentSuggestions');
  var form      = document.getElementById('searchStudentForm');
  var ctxPath   = '${pageContext.request.contextPath}';
  var timer;

  if (!input || !dropdown) return;

  input.addEventListener('input', function () {
    clearTimeout(timer);
    var q = this.value.trim();
    if (q.length < 2) { hide(); return; }
    timer = setTimeout(function () { fetchStudents(q); }, 250);
  });

  function fetchStudents(q) {
    fetch(ctxPath + '/admin/students?q=' + encodeURIComponent(q) + '&format=json')
      .then(function (r) { return r.json(); })
      .then(function (list) { render(list); })
      .catch(function () { hide(); });
  }

  function render(list) {
    dropdown.innerHTML = '';
    if (!list || list.length === 0) { hide(); return; }

    list.slice(0, 8).forEach(function (s) {
      var row = document.createElement('div');
      row.style.cssText = 'display:flex;align-items:center;gap:10px;padding:9px 14px;cursor:pointer;border-bottom:1px solid #eee;';
      row.onmouseenter = function () { this.style.background = '#f5f0e8'; };
      row.onmouseleave = function () { this.style.background = ''; };

      // Avatar
      var av = document.createElement('div');
      if (s.profilePicture) {
        av.innerHTML = '<img src="' + ctxPath + '/uploads/profiles/' + s.profilePicture +
          '" style="width:38px;height:38px;border-radius:50%;object-fit:cover;border:2px solid #1b3a6b;flex-shrink:0">';
      } else {
        var ini = (s.name || '  ').split(' ').map(function (w) { return w[0] || ''; }).slice(0, 2).join('').toUpperCase();
        av.style.cssText = 'width:38px;height:38px;border-radius:50%;background:#1b3a6b;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.85rem;flex-shrink:0';
        av.textContent = ini;
      }

      // Text
      var txt = document.createElement('div');
      txt.style.flex = '1';
      txt.style.minWidth = '0';
      txt.innerHTML =
        '<div style="font-weight:700;font-size:0.88rem;color:#1b3a6b;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + esc(s.name) + '</div>' +
        '<div style="font-size:0.76rem;color:#888;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + esc(s.studentId) + ' &bull; ' + esc(s.email) + '</div>';

      row.appendChild(av);
      row.appendChild(txt);

      row.addEventListener('mousedown', function (e) {
        e.preventDefault();
        input.value = s.studentId;
        hide();
        form.submit();
      });

      dropdown.appendChild(row);
    });

    dropdown.style.display = 'block';
  }

  function hide() { dropdown.style.display = 'none'; }

  function esc(str) {
    return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  // Close on outside click
  document.addEventListener('click', function (e) {
    if (!input.contains(e.target) && !dropdown.contains(e.target)) hide();
  });

  // Keyboard navigation
  input.addEventListener('keydown', function (e) {
    var rows = dropdown.querySelectorAll('div[style*="cursor:pointer"]');
    var cur  = Array.from(rows).findIndex(function (r) { return r.dataset.active === '1'; });

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (cur >= 0) { rows[cur].dataset.active = ''; rows[cur].style.background = ''; }
      var ni = (cur + 1) % rows.length;
      rows[ni].dataset.active = '1'; rows[ni].style.background = '#f5f0e8';
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (cur >= 0) { rows[cur].dataset.active = ''; rows[cur].style.background = ''; }
      var pi = (cur - 1 + rows.length) % rows.length;
      rows[pi].dataset.active = '1'; rows[pi].style.background = '#f5f0e8';
    } else if (e.key === 'Enter' && cur >= 0) {
      e.preventDefault();
      rows[cur].dispatchEvent(new MouseEvent('mousedown'));
    } else if (e.key === 'Escape') {
      hide();
    }
  });
}());

// ── Issue Book Confirmation ──────────────────────────────────────────────────
<c:if test="${not empty student}">
document.getElementById('issueBookForm').addEventListener('submit', function (e) {
  e.preventDefault();
  var bookSel  = document.getElementById('bookId');
  var daysSel  = document.getElementById('dueDays');
  var bookText = bookSel.options[bookSel.selectedIndex].text;
  var days     = daysSel.value;

  if (!bookSel.value) {
    Swal.fire({ icon: 'warning', title: 'No Book Selected', text: 'Please select a book to issue.' });
    return;
  }

  var due = new Date();
  due.setDate(due.getDate() + parseInt(days));
  var dueStr = due.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });

  Swal.fire({
    icon: 'question',
    title: '📤 Confirm Book Issue',
    html: '<div style="text-align:left;padding:10px">' +
          '<p><strong>Student:</strong> ${student.fullName}</p>' +
          '<p><strong>Student ID:</strong> ${student.studentId}</p>' +
          '<p><strong>Book:</strong> ' + bookText + '</p>' +
          '<p><strong>Loan Duration:</strong> ' + days + ' days</p>' +
          '<p><strong>Due Date:</strong> ' + dueStr + '</p>' +
          '</div>',
    showCancelButton: true,
    confirmButtonText: 'Yes, Issue Book',
    cancelButtonText: 'Cancel',
    reverseButtons: true
  }).then(function (result) {
    if (result.isConfirmed) {
      Swal.fire({ title: 'Processing...', allowOutsideClick: false, didOpen: function () { Swal.showLoading(); } });
      document.getElementById('issueBookForm').submit();
    }
  });
});
</c:if>
</script>
</body>
</html>
