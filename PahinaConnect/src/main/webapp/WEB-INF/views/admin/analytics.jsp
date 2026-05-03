<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Analytics - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    .analytics-card {
      background:#fff; border-radius:var(--radius); box-shadow:var(--shadow);
      overflow:hidden; transition:var(--transition);
    }
    .analytics-card:hover { box-shadow:var(--shadow-lg); transform:translateY(-2px); }
    .chart-header {
      padding:16px 20px; border-bottom:1px solid var(--cream-dark);
      display:flex; align-items:center; justify-content:space-between;
    }
    .chart-header h3 { margin:0; font-size:1rem; color:var(--green-dark); }
    .chart-body { padding:20px; }
    .stat-ring {
      width:80px; height:80px; border-radius:50%;
      display:flex; align-items:center; justify-content:center;
      font-size:1.8rem; font-weight:800;
    }
  </style>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📊 Analytics Dashboard</span>
      <span style="font-size:0.85rem;color:var(--text-light)">
        <fmt:formatDate value="<%= new java.util.Date() %>" pattern="MMMM dd, yyyy"/>
      </span>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <!-- KPI Cards -->
      <div class="grid grid-4 mb-3">
        <div class="stat-card">
          <div class="stat-icon" style="background:linear-gradient(135deg,#2C5F2E,#3D7A40);border-radius:12px">
            <span style="font-size:1.6rem">📚</span>
          </div>
          <div>
            <div class="stat-value">${totalBooks}</div>
            <div class="stat-label">Total Books</div>
          </div>
        </div>
        <div class="stat-card info">
          <div class="stat-icon" style="background:linear-gradient(135deg,#1a6b9a,#2980B9);border-radius:12px">
            <span style="font-size:1.6rem">👥</span>
          </div>
          <div>
            <div class="stat-value">${totalStudents}</div>
            <div class="stat-label">Active Students</div>
          </div>
        </div>
        <div class="stat-card gold">
          <div class="stat-icon" style="background:linear-gradient(135deg,#C8881A,#E8A838);border-radius:12px">
            <span style="font-size:1.6rem">📤</span>
          </div>
          <div>
            <div class="stat-value">${activeIssues}</div>
            <div class="stat-label">Active Issues</div>
          </div>
        </div>
        <div class="stat-card danger">
          <div class="stat-icon" style="background:linear-gradient(135deg,#8B0000,#C0392B);border-radius:12px">
            <span style="font-size:1.6rem">⚠️</span>
          </div>
          <div>
            <div class="stat-value">${overdueIssues}</div>
            <div class="stat-label">Overdue Books</div>
          </div>
        </div>
      </div>

      <!-- Charts Row 1 -->
      <div class="grid grid-2 mb-3">
        <!-- Monthly Issues Bar Chart -->
        <div class="analytics-card">
          <div class="chart-header">
            <h3>📈 Monthly Issues (Last 6 Months)</h3>
            <span class="badge badge-green">Trend</span>
          </div>
          <div class="chart-body">
            <canvas id="monthlyChart" height="220"></canvas>
          </div>
        </div>

        <!-- Category Doughnut -->
        <div class="analytics-card">
          <div class="chart-header">
            <h3>🗂️ Borrows by Category</h3>
            <span class="badge badge-gold">Distribution</span>
          </div>
          <div class="chart-body">
            <canvas id="categoryChart" height="220"></canvas>
          </div>
        </div>
      </div>

      <!-- Charts Row 2 -->
      <div class="grid grid-2 mb-3">
        <!-- Overdue Rate Gauge -->
        <div class="analytics-card">
          <div class="chart-header">
            <h3>📊 Issue Status Overview</h3>
            <span class="badge badge-info">Status</span>
          </div>
          <div class="chart-body">
            <canvas id="statusChart" height="220"></canvas>
          </div>
        </div>

        <!-- Fine Summary -->
        <div class="analytics-card">
          <div class="chart-header">
            <h3>💰 Fine & Overdue Summary</h3>
            <span class="badge badge-danger">Fines</span>
          </div>
          <div class="chart-body">
            <div class="grid grid-2" style="gap:16px;margin-bottom:20px">
              <div style="text-align:center;padding:20px;background:var(--cream);border-radius:var(--radius)">
                <div style="font-size:2rem;font-weight:800;color:var(--danger)">
                  ₱<fmt:formatNumber value="${totalFines}" pattern="#,##0.00"/>
                </div>
                <div style="font-size:0.82rem;color:var(--text-light);margin-top:4px">Unpaid Fines</div>
              </div>
              <div style="text-align:center;padding:20px;background:var(--cream);border-radius:var(--radius)">
                <div style="font-size:2rem;font-weight:800;color:var(--warning)">${overdueRate}%</div>
                <div style="font-size:0.82rem;color:var(--text-light);margin-top:4px">Overdue Rate</div>
              </div>
            </div>
            <canvas id="fineChart" height="130"></canvas>
          </div>
        </div>
      </div>

      <!-- Most Borrowed Books -->
      <div class="analytics-card mb-3">
        <div class="chart-header">
          <h3>🏆 Most Borrowed Books (Top 10)</h3>
          <span class="badge badge-green">Popularity</span>
        </div>
        <div class="chart-body" style="padding:0 20px 20px">
          <canvas id="topBooksChart" height="120"></canvas>
        </div>
      </div>

      <!-- Books Table -->
      <div class="analytics-card">
        <div class="chart-header"><h3>📋 Top Books Detail</h3></div>
        <div style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead><tr><th>Rank</th><th>Title</th><th>Author</th><th>Category</th><th>Available</th></tr></thead>
              <tbody>
                <c:forEach var="book" items="${mostBorrowed}" varStatus="s">
                  <tr>
                    <td>
                      <c:choose>
                        <c:when test="${s.index eq 0}"><span style="font-size:1.4rem">🥇</span></c:when>
                        <c:when test="${s.index eq 1}"><span style="font-size:1.4rem">🥈</span></c:when>
                        <c:when test="${s.index eq 2}"><span style="font-size:1.4rem">🥉</span></c:when>
                        <c:otherwise><span class="badge badge-gold">${s.index+1}</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td><strong>${book.title}</strong></td>
                    <td>${book.authorName}</td>
                    <td><span class="badge badge-green">${book.categoryName}</span></td>
                    <td>
                      <c:choose>
                        <c:when test="${book.availableCopies gt 0}">
                          <span class="badge badge-success">${book.availableCopies}/${book.totalCopies}</span>
                        </c:when>
                        <c:otherwise><span class="badge badge-danger">0/${book.totalCopies}</span></c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty mostBorrowed}">
                  <tr><td colspan="5" class="text-center text-muted" style="padding:20px">No data yet.</td></tr>
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
Chart.defaults.font.family = "'Segoe UI', sans-serif";
Chart.defaults.color = '#555';

// ── Monthly Issues Bar Chart ─────────────────────────────
const monthlyLabels = [<c:forEach var="m" items="${monthlyStats}" varStatus="s">'${m.month}'<c:if test="${!s.last}">,</c:if></c:forEach>];
const monthlyData   = [<c:forEach var="m" items="${monthlyStats}" varStatus="s">${m.count}<c:if test="${!s.last}">,</c:if></c:forEach>];

new Chart(document.getElementById('monthlyChart'), {
  type: 'bar',
  data: {
    labels: monthlyLabels.length ? monthlyLabels : ['No Data'],
    datasets: [{
      label: 'Books Issued',
      data: monthlyData.length ? monthlyData : [0],
      backgroundColor: function(ctx) {
        var g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 200);
        g.addColorStop(0, 'rgba(44,95,46,0.9)');
        g.addColorStop(1, 'rgba(44,95,46,0.3)');
        return g;
      },
      borderColor: '#2C5F2E',
      borderWidth: 2,
      borderRadius: 8,
      borderSkipped: false
    }]
  },
  options: {
    responsive: true,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: '#2C5F2E',
        titleColor: '#F5F0E8',
        bodyColor: '#97BC62',
        padding: 12,
        cornerRadius: 8,
        callbacks: { label: function(c) { return ' ' + c.raw + ' books issued'; } }
      }
    },
    scales: {
      y: { beginAtZero: true, ticks: { precision: 0 }, grid: { color: 'rgba(0,0,0,0.05)' } },
      x: { grid: { display: false } }
    }
  }
});

// ── Category Doughnut ────────────────────────────────────
const catLabels = [<c:forEach var="c" items="${categoryStats}" varStatus="s">'${c.name}'<c:if test="${!s.last}">,</c:if></c:forEach>];
const catData   = [<c:forEach var="c" items="${categoryStats}" varStatus="s">${c.count}<c:if test="${!s.last}">,</c:if></c:forEach>];
const palette   = ['#2C5F2E','#E8A838','#3D7A40','#C8881A','#1E4220','#F0BC5E','#97BC62','#C0392B','#2980B9','#8E44AD'];

new Chart(document.getElementById('categoryChart'), {
  type: 'doughnut',
  data: {
    labels: catLabels.length ? catLabels : ['No Data'],
    datasets: [{
      data: catData.length ? catData : [1],
      backgroundColor: palette,
      borderWidth: 3,
      borderColor: '#fff',
      hoverOffset: 8
    }]
  },
  options: {
    responsive: true,
    cutout: '65%',
    plugins: {
      legend: { position: 'right', labels: { padding: 16, usePointStyle: true, pointStyleWidth: 10 } },
      tooltip: {
        backgroundColor: '#2C5F2E', titleColor: '#F5F0E8', bodyColor: '#97BC62',
        padding: 12, cornerRadius: 8
      }
    }
  }
});

// ── Status Pie ───────────────────────────────────────────
new Chart(document.getElementById('statusChart'), {
  type: 'pie',
  data: {
    labels: ['Active Issues', 'Overdue', 'Available Books'],
    datasets: [{
      data: [${activeIssues} - ${overdueIssues}, ${overdueIssues}, ${availableBooks}],
      backgroundColor: ['#2C5F2E', '#C0392B', '#E8A838'],
      borderWidth: 3, borderColor: '#fff', hoverOffset: 8
    }]
  },
  options: {
    responsive: true,
    plugins: {
      legend: { position: 'bottom', labels: { padding: 16, usePointStyle: true } },
      tooltip: { backgroundColor: '#2C5F2E', titleColor: '#F5F0E8', bodyColor: '#97BC62', padding: 12, cornerRadius: 8 }
    }
  }
});

// ── Fine Trend Line ──────────────────────────────────────
new Chart(document.getElementById('fineChart'), {
  type: 'line',
  data: {
    labels: monthlyLabels.length ? monthlyLabels : ['No Data'],
    datasets: [{
      label: 'Issues',
      data: monthlyData.length ? monthlyData : [0],
      borderColor: '#C0392B',
      backgroundColor: 'rgba(192,57,43,0.1)',
      borderWidth: 2,
      fill: true,
      tension: 0.4,
      pointBackgroundColor: '#C0392B',
      pointRadius: 4
    }]
  },
  options: {
    responsive: true,
    plugins: { legend: { display: false } },
    scales: {
      y: { beginAtZero: true, ticks: { precision: 0 }, grid: { color: 'rgba(0,0,0,0.05)' } },
      x: { grid: { display: false } }
    }
  }
});

// ── Top Books Horizontal Bar ─────────────────────────────
const topTitles = [<c:forEach var="b" items="${mostBorrowed}" varStatus="s">'${b.title.length() > 25 ? b.title.substring(0,25).concat("...") : b.title}'<c:if test="${!s.last}">,</c:if></c:forEach>];
const topCounts = [<c:forEach var="b" items="${mostBorrowed}" varStatus="s">
  <c:set var="cnt" value="0"/>
  ${cnt}<c:if test="${!s.last}">,</c:if>
</c:forEach>];

new Chart(document.getElementById('topBooksChart'), {
  type: 'bar',
  data: {
    labels: topTitles.length ? topTitles : ['No Data'],
    datasets: [{
      label: 'Times Borrowed',
      data: topCounts.length ? topCounts : [0],
      backgroundColor: palette.slice(0, topTitles.length),
      borderRadius: 6,
      borderSkipped: false
    }]
  },
  options: {
    indexAxis: 'y',
    responsive: true,
    plugins: {
      legend: { display: false },
      tooltip: { backgroundColor: '#2C5F2E', titleColor: '#F5F0E8', bodyColor: '#97BC62', padding: 12, cornerRadius: 8 }
    },
    scales: {
      x: { beginAtZero: true, ticks: { precision: 0 }, grid: { color: 'rgba(0,0,0,0.05)' } },
      y: { grid: { display: false } }
    }
  }
});
</script>
</body>
</html>
