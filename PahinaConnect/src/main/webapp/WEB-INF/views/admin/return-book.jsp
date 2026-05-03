<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Return Book - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📥 Return Book</span>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <div class="search-bar">
        <div class="search-input-wrap">
          <span class="search-icon">🔍</span>
          <input type="text" id="tableSearch" class="form-control" placeholder="Search by student name, ID, or book title...">
        </div>
        <span style="font-size:0.85rem;color:var(--text-light)">
          Fine rate: ₱${finePerDay}/day | Max: ₱${maxFine}
        </span>
      </div>

      <div class="card">
        <div class="card-header"><h3>📤 Active Issues (${activeIssues.size()})</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr><th>#</th><th>Student</th><th>Book</th><th>Issue Date</th><th>Due Date</th><th>Status</th><th>Fine</th><th>Action</th></tr>
              </thead>
              <tbody>
                <c:forEach var="issue" items="${activeIssues}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td>
                      <strong>${issue.studentName}</strong><br>
                      <small class="text-muted">${issue.studentIdCode}</small>
                    </td>
                    <td>${issue.bookTitle}</td>
                    <td><fmt:formatDate value="${issue.issueDate}" pattern="MMM dd, yyyy"/></td>
                    <td>
                      <fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${issue.status eq 'overdue'}">
                          <span class="badge badge-danger">Overdue (${issue.daysOverdue}d)</span>
                        </c:when>
                        <c:otherwise><span class="badge badge-success">Active</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:if test="${issue.status eq 'overdue'}">
                        <span class="text-danger fw-bold">
                          ₱<fmt:formatNumber value="${issue.daysOverdue * finePerDay > maxFine ? maxFine : issue.daysOverdue * finePerDay}" pattern="#,##0.00"/>
                        </span>
                      </c:if>
                      <c:if test="${issue.status ne 'overdue'}">—</c:if>
                    </td>
                    <td>
                      <button class="btn btn-sm btn-primary"
                              onclick="returnBook(${issue.id},'${issue.studentName}','${issue.bookTitle}',
                                '${issue.status}',${issue.daysOverdue},${finePerDay},${maxFine})">
                        📥 Return
                      </button>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty activeIssues}">
                  <tr><td colspan="8" class="text-center text-muted" style="padding:30px">No active issues.</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
function returnBook(issueId, student, book, status, daysOverdue, finePerDay, maxFine) {
  let fine = 0;
  if (status === 'overdue') {
    fine = Math.min(daysOverdue * finePerDay, maxFine);
  }
  
  let html = '<div style="text-align:left;padding:10px">' +
             '<p><strong>Student:</strong> ' + student + '</p>' +
             '<p><strong>Book:</strong> ' + book + '</p>';
  
  if (fine > 0) {
    html += '<p style="color:#C0392B;font-size:1.1rem;margin-top:10px"><strong>⚠️ Fine Amount: ₱' + fine.toFixed(2) + '</strong></p>' +
            '<p style="color:#7A8FA8;font-size:0.9rem">(' + daysOverdue + ' days overdue @ ₱' + finePerDay + '/day)</p>' +
            '<div style="margin-top:15px;padding:12px;background:#FEF8E7;border-left:3px solid #B7770D;border-radius:4px">' +
            '<p style="margin:0;font-size:0.85rem;color:#B7770D">⚠️ Please collect the fine before processing return.</p>' +
            '</div>';
  } else {
    html += '<p style="color:#1E6B3C;margin-top:10px"><strong>✅ No fine applicable</strong></p>';
  }
  
  html += '</div>';
  
  Swal.fire({
    icon: fine > 0 ? 'warning' : 'question',
    title: '📥 Confirm Book Return',
    html: html,
    showCancelButton: true,
    confirmButtonText: fine > 0 ? 'Return & Collect Fine' : 'Confirm Return',
    cancelButtonText: 'Cancel',
    reverseButtons: true,
    customClass: {
      confirmButton: fine > 0 ? 'swal2-gold' : ''
    },
    focusCancel: fine > 0
  }).then(function(result) {
    if (result.isConfirmed) {
      // Show loading
      Swal.fire({
        title: 'Processing Return...',
        html: 'Please wait while we process the book return.',
        allowOutsideClick: false,
        allowEscapeKey: false,
        didOpen: function() {
          Swal.showLoading();
        }
      });
      
      // Submit form
      var form = document.createElement('form');
      form.method = 'POST';
      form.action = '${pageContext.request.contextPath}/admin/return-book';
      
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'issueId';
      input.value = issueId;
      form.appendChild(input);
      
      if (fine > 0) {
        var fineInput = document.createElement('input');
        fineInput.type = 'hidden';
        fineInput.name = 'finePaid';
        fineInput.value = 'true';
        form.appendChild(fineInput);
      }
      
      document.body.appendChild(form);
      form.submit();
    }
  });
}
</script>
</body>
</html>
