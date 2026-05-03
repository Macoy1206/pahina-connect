<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Email Reminders - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📧 Email Reminders</span>
      <div class="topbar-actions">
        <span style="font-size:0.85rem;color:var(--text-light)">Force-send reminders to students</span>
      </div>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <c:if test="${not empty success}">
        <div class="alert alert-success">✅ ${success}</div>
      </c:if>
      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ ${error}</div>
      </c:if>

      <!-- Bulk Action Cards -->
      <div class="grid grid-2 mb-3">

        <!-- Overdue Notices -->
        <div class="card" style="border-top:4px solid var(--danger)">
          <div class="card-header" style="background:linear-gradient(135deg,#7f0000,#C0392B)">
            <h3>🚨 Overdue Book Notices</h3>
          </div>
          <div class="card-body">
            <p style="color:var(--text-mid);font-size:0.9rem;margin:0 0 16px">
              Send overdue notices to all students with books past their due date.
            </p>
            <div style="background:var(--danger-light);border-radius:8px;padding:14px;margin-bottom:16px;display:flex;align-items:center;gap:12px">
              <span style="font-size:2rem">⚠️</span>
              <div>
                <div style="font-size:1.6rem;font-weight:800;color:var(--danger)">${overdue.size()}</div>
                <div style="font-size:0.82rem;color:var(--text-light)">students with overdue books</div>
              </div>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/reminders"
                  onsubmit="return confirm('Send overdue notices to all ${overdue.size()} students?')">
              <input type="hidden" name="action" value="sendOverdue">
              <button type="submit" class="btn btn-danger btn-block" ${empty overdue ? 'disabled' : ''}>
                🚨 Send All Overdue Notices (${overdue.size()})
              </button>
            </form>
          </div>
        </div>

        <!-- Due Soon Reminders -->
        <div class="card" style="border-top:4px solid var(--gold)">
          <div class="card-header" style="background:linear-gradient(135deg,#A8893E,#C8A96E)">
            <h3>⏰ Due Soon Reminders</h3>
          </div>
          <div class="card-body">
            <p style="color:var(--text-mid);font-size:0.9rem;margin:0 0 16px">
              Send reminders to students whose books are due within the next <strong>3 days</strong>.
            </p>
            <div style="background:var(--gold-pale);border-radius:8px;padding:14px;margin-bottom:16px;display:flex;align-items:center;gap:12px">
              <span style="font-size:2rem">📅</span>
              <div>
                <div style="font-size:1.6rem;font-weight:800;color:var(--gold-dark)">${dueSoon.size()}</div>
                <div style="font-size:0.82rem;color:var(--text-light)">books due in next 3 days</div>
              </div>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/reminders"
                  onsubmit="return confirm('Send due-soon reminders to all ${dueSoon.size()} students?')">
              <input type="hidden" name="action" value="sendDueSoon">
              <button type="submit" class="btn btn-gold btn-block"
                      ${empty dueSoon ? 'disabled' : ''}>
                ⏰ Send All Due-Soon Reminders (${dueSoon.size()})
              </button>
            </form>
          </div>
        </div>
      </div>

      <!-- ⚡ FORCE TEST — Send to ALL active borrowers regardless of due date -->
      <div class="card mb-3" style="border-top:4px solid var(--navy)">
        <div class="card-header" style="background:linear-gradient(135deg,#0F2347,#1B3A6B)">
          <h3>⚡ Force Send — Test Reminder</h3>
          <span style="color:rgba(255,255,255,0.6);font-size:0.82rem">For testing only — ignores due date</span>
        </div>
        <div class="card-body">
          <div style="display:flex;align-items:center;gap:20px;flex-wrap:wrap">
            <div style="background:var(--info-light);border-radius:8px;padding:14px 20px;display:flex;align-items:center;gap:12px">
              <span style="font-size:2rem">📬</span>
              <div>
                <div style="font-size:1.6rem;font-weight:800;color:var(--navy)">${allActive.size()}</div>
                <div style="font-size:0.82rem;color:var(--text-light)">total active borrowers</div>
              </div>
            </div>
            <div style="flex:1">
              <p style="color:var(--text-mid);font-size:0.9rem;margin:0 0 12px">
                Sends a <strong>due date reminder email</strong> to <strong>every student</strong> who currently has a book issued —
                regardless of whether it's due soon or not. Use this to test that email is working.
              </p>
              <form method="post" action="${pageContext.request.contextPath}/admin/reminders"
                    onsubmit="return confirm('Force send reminder to ALL ${allActive.size()} active borrowers?')">
                <input type="hidden" name="action" value="sendForceAll">
                <button type="submit" class="btn btn-primary" ${empty allActive ? 'disabled' : ''}>
                  ⚡ Force Send to All Active Borrowers (${allActive.size()})
                </button>
              </form>
            </div>
          </div>

          <!-- Individual force send per active issue -->
          <c:if test="${not empty allActive}">
            <div class="table-wrapper" style="margin-top:16px">
              <table>
                <thead>
                  <tr><th>#</th><th>Student</th><th>Email</th><th>Book</th><th>Due Date</th><th>Status</th><th>Action</th></tr>
                </thead>
                <tbody>
                  <c:forEach var="issue" items="${allActive}" varStatus="s">
                    <tr>
                      <td>${s.index+1}</td>
                      <td><strong>${issue.studentName}</strong><br><small class="text-muted">${issue.studentIdCode}</small></td>
                      <td style="font-size:0.82rem">${issue.studentEmail}</td>
                      <td>${issue.bookTitle}</td>
                      <td><fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${issue.status eq 'overdue'}"><span class="badge badge-danger">Overdue</span></c:when>
                          <c:otherwise><span class="badge badge-success">Active</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <form method="post" action="${pageContext.request.contextPath}/admin/reminders" style="display:inline">
                          <input type="hidden" name="action" value="sendSingle">
                          <input type="hidden" name="issueId" value="${issue.id}">
                          <input type="hidden" name="type" value="reminder">
                          <button type="submit" class="btn btn-sm btn-primary"
                                  onclick="return confirm('Force send reminder to ${issue.studentName}?')">
                            📧 Send
                          </button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:if>
        </div>
      </div>

      <!-- Overdue List -->
      <div class="card mb-3">
        <div class="card-header" style="background:linear-gradient(135deg,#7f0000,#C0392B)">
          <h3>🚨 Overdue Books — Individual Reminders</h3>
          <span style="color:rgba(255,255,255,0.7);font-size:0.82rem">${overdue.size()} records</span>
        </div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Student</th>
                  <th>Email</th>
                  <th>Book</th>
                  <th>Due Date</th>
                  <th>Days Overdue</th>
                  <th>Fine</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="issue" items="${overdue}" varStatus="s">
                  <tr>
                    <td>${s.index + 1}</td>
                    <td>
                      <strong>${issue.studentName}</strong><br>
                      <small class="text-muted">${issue.studentIdCode}</small>
                    </td>
                    <td style="font-size:0.82rem">${issue.studentEmail}</td>
                    <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                      ${issue.bookTitle}
                    </td>
                    <td>
                      <span style="color:var(--danger);font-weight:600">
                        <fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/>
                      </span>
                    </td>
                    <td>
                      <span class="badge badge-danger">${issue.daysOverdue} days</span>
                    </td>
                    <td>
                      <strong style="color:var(--danger)">
                        ₱<fmt:formatNumber value="${issue.daysOverdue * 5.0 > 500 ? 500 : issue.daysOverdue * 5.0}" pattern="#,##0.00"/>
                      </strong>
                    </td>
                    <td>
                      <form method="post" action="${pageContext.request.contextPath}/admin/reminders" style="display:inline">
                        <input type="hidden" name="action" value="sendSingle">
                        <input type="hidden" name="issueId" value="${issue.id}">
                        <input type="hidden" name="type" value="overdue">
                        <button type="submit" class="btn btn-sm btn-danger"
                                onclick="return confirm('Send overdue notice to ${issue.studentName}?')">
                          📧 Send
                        </button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty overdue}">
                  <tr>
                    <td colspan="8" class="text-center text-muted" style="padding:30px">
                      <span style="font-size:2rem">✅</span><br>
                      No overdue books at this time.
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Due Soon List -->
      <div class="card">
        <div class="card-header" style="background:linear-gradient(135deg,#A8893E,#C8A96E)">
          <h3>⏰ Books Due in Next 3 Days — Individual Reminders</h3>
          <span style="color:rgba(255,255,255,0.7);font-size:0.82rem">${dueSoon.size()} records</span>
        </div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Student</th>
                  <th>Email</th>
                  <th>Book</th>
                  <th>Due Date</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="issue" items="${dueSoon}" varStatus="s">
                  <tr>
                    <td>${s.index + 1}</td>
                    <td>
                      <strong>${issue.studentName}</strong><br>
                      <small class="text-muted">${issue.studentIdCode}</small>
                    </td>
                    <td style="font-size:0.82rem">${issue.studentEmail}</td>
                    <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                      ${issue.bookTitle}
                    </td>
                    <td>
                      <span style="color:var(--gold-dark);font-weight:600">
                        <fmt:formatDate value="${issue.dueDate}" pattern="MMM dd, yyyy"/>
                      </span>
                    </td>
                    <td>
                      <form method="post" action="${pageContext.request.contextPath}/admin/reminders" style="display:inline">
                        <input type="hidden" name="action" value="sendSingle">
                        <input type="hidden" name="issueId" value="${issue.id}">
                        <input type="hidden" name="type" value="reminder">
                        <button type="submit" class="btn btn-sm btn-gold"
                                onclick="return confirm('Send due-soon reminder to ${issue.studentName}?')">
                          📧 Send
                        </button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty dueSoon}">
                  <tr>
                    <td colspan="6" class="text-center text-muted" style="padding:30px">
                      <span style="font-size:2rem">✅</span><br>
                      No books due in the next 3 days.
                    </td>
                  </tr>
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
</body>
</html>
