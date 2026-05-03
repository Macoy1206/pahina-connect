/* ============================================================
   Pahina Connect - Main JavaScript with SweetAlert2
   ============================================================ */

// ── SweetAlert2 Custom Theme Configuration ─────────────────
(function() {
  // Inject custom SweetAlert2 styles for Pahina Connect theme
  var style = document.createElement('style');
  style.textContent = `
    /* SweetAlert2 Custom Theme - Navy & Gold */
    .swal2-popup {
      border-radius: 16px !important;
      padding: 2em !important;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
    }
    .swal2-title {
      color: #0F2347 !important;
      font-size: 1.5rem !important;
      font-weight: 800 !important;
      padding: 0.5em 0 !important;
    }
    .swal2-html-container {
      color: #3D5070 !important;
      font-size: 1rem !important;
      line-height: 1.6 !important;
    }
    .swal2-icon {
      border-width: 3px !important;
      margin: 1.5em auto 1em !important;
    }
    .swal2-icon.swal2-warning {
      border-color: #C8A96E !important;
      color: #C8A96E !important;
    }
    .swal2-icon.swal2-error {
      border-color: #C0392B !important;
    }
    .swal2-icon.swal2-success {
      border-color: #1E6B3C !important;
    }
    .swal2-icon.swal2-info {
      border-color: #1B3A6B !important;
    }
    .swal2-icon.swal2-question {
      border-color: #1B3A6B !important;
      color: #1B3A6B !important;
    }
    .swal2-confirm {
      background: #1B3A6B !important;
      border-radius: 8px !important;
      padding: 10px 28px !important;
      font-weight: 700 !important;
      font-size: 0.95rem !important;
      box-shadow: 0 4px 12px rgba(27,58,107,0.25) !important;
      transition: all 0.2s ease !important;
    }
    .swal2-confirm:hover {
      background: #0F2347 !important;
      transform: translateY(-1px) !important;
      box-shadow: 0 6px 16px rgba(27,58,107,0.35) !important;
    }
    .swal2-cancel {
      background: #F8F4EE !important;
      color: #3D5070 !important;
      border: 1.5px solid #DDD0BC !important;
      border-radius: 8px !important;
      padding: 10px 28px !important;
      font-weight: 700 !important;
      font-size: 0.95rem !important;
      transition: all 0.2s ease !important;
    }
    .swal2-cancel:hover {
      background: #EDE5D8 !important;
      border-color: #C8A96E !important;
    }
    .swal2-deny {
      background: #C0392B !important;
      border-radius: 8px !important;
      padding: 10px 28px !important;
      font-weight: 700 !important;
      font-size: 0.95rem !important;
      box-shadow: 0 4px 12px rgba(192,57,43,0.25) !important;
    }
    .swal2-deny:hover {
      background: #96281b !important;
    }
    .swal2-actions {
      gap: 12px !important;
      margin-top: 1.5em !important;
    }
    .swal2-styled:focus {
      box-shadow: 0 0 0 3px rgba(27,58,107,0.25) !important;
    }
    /* Gold variant for special actions */
    .swal2-confirm.swal2-gold {
      background: #C8A96E !important;
    }
    .swal2-confirm.swal2-gold:hover {
      background: #A8893E !important;
    }
    /* Danger variant */
    .swal2-confirm.swal2-danger {
      background: #C0392B !important;
    }
    .swal2-confirm.swal2-danger:hover {
      background: #96281b !important;
    }
  `;
  document.head.appendChild(style);

  // SweetAlert2 wrapper functions with Pahina Connect theme
  window.pcConfirm = function(options) {
    var type = options.type || 'warning';
    var iconType = type === 'danger' ? 'error' : type === 'warn' ? 'warning' : type;
    
    return Swal.fire({
      icon: iconType,
      title: options.title || 'Are you sure?',
      html: options.message || '',
      showCancelButton: true,
      confirmButtonText: options.confirmText || 'Yes, proceed',
      cancelButtonText: options.cancelText || 'Cancel',
      customClass: {
        confirmButton: type === 'danger' ? 'swal2-danger' : (type === 'gold' ? 'swal2-gold' : ''),
      },
      buttonsStyling: true,
      reverseButtons: true,
      focusCancel: type === 'danger',
      allowOutsideClick: false,
      allowEscapeKey: true,
    }).then(function(result) {
      return result.isConfirmed;
    });
  };

  window.pcAlert = function(title, message, type) {
    var iconType = type === 'danger' ? 'error' : type === 'warn' ? 'warning' : type || 'info';
    
    return Swal.fire({
      icon: iconType,
      title: title,
      html: message || '',
      confirmButtonText: 'OK',
      buttonsStyling: true,
      allowOutsideClick: true,
    });
  };

  // Success toast notification
  window.pcToast = function(message, type) {
    const Toast = Swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true,
      didOpen: (toast) => {
        toast.addEventListener('mouseenter', Swal.stopTimer);
        toast.addEventListener('mouseleave', Swal.resumeTimer);
      }
    });

    Toast.fire({
      icon: type || 'success',
      title: message
    });
  };
})();

// ── Intercept all confirm() forms and links ──────────────────
document.addEventListener('DOMContentLoaded', function() {

  // ── data-confirm forms ──────────────────────────────────────
  document.querySelectorAll('form[data-confirm]').forEach(function(form) {
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      var opts = {
        type:        form.dataset.confirmType    || 'warn',
        icon:        form.dataset.confirmIcon    || undefined,
        title:       form.dataset.confirmTitle   || 'Are you sure?',
        message:     form.dataset.confirm        || '',
        confirmText: form.dataset.confirmOk      || 'Yes, proceed',
        cancelText:  form.dataset.confirmCancel  || 'Cancel'
      };
      pcConfirm(opts).then(function(ok) { if (ok) form.submit(); });
    });
  });

  // ── data-confirm links/buttons ──────────────────────────────
  document.querySelectorAll('a[data-confirm], button[data-confirm]').forEach(function(el) {
    el.addEventListener('click', function(e) {
      e.preventDefault();
      var href = el.getAttribute('href') || el.dataset.href;
      var opts = {
        type:        el.dataset.confirmType    || 'warn',
        icon:        el.dataset.confirmIcon    || undefined,
        title:       el.dataset.confirmTitle   || 'Are you sure?',
        message:     el.dataset.confirm        || '',
        confirmText: el.dataset.confirmOk      || 'Yes, proceed',
        cancelText:  el.dataset.confirmCancel  || 'Cancel'
      };
      pcConfirm(opts).then(function(ok) {
        if (ok && href) window.location.href = href;
        else if (ok && el.closest('form')) el.closest('form').submit();
      });
    });
  });

  // ── Password eye toggle ─────────────────────────────────────
  var eyeOpenSVG = '<svg class="eye-open" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>';
  var eyeClosedSVG = '<svg class="eye-closed" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/></svg>';

  document.querySelectorAll('input[type="password"]').forEach(function(input) {
    if (input.closest('.password-wrapper')) return;
    var wrapper = document.createElement('div');
    wrapper.className = 'password-wrapper';
    input.parentNode.insertBefore(wrapper, input);
    wrapper.appendChild(input);
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'password-toggle';
    btn.setAttribute('aria-label', 'Show password');
    btn.setAttribute('tabindex', '-1');
    btn.innerHTML = eyeOpenSVG + eyeClosedSVG;
    btn.addEventListener('click', function() { togglePasswordVisibility(btn); });
    wrapper.appendChild(btn);
  });

  // ── Alert auto-dismiss ──────────────────────────────────────
  document.querySelectorAll('.alert[data-auto-dismiss]').forEach(function(alert) {
    setTimeout(function() {
      alert.style.opacity = '0';
      alert.style.transition = 'opacity 0.5s';
      setTimeout(function() { alert.remove(); }, 500);
    }, 4000);
  });

  // ── Active nav link ─────────────────────────────────────────
  var currentPath = window.location.pathname;
  document.querySelectorAll('.nav-link').forEach(function(link) {
    if (link.getAttribute('href') && currentPath.includes(link.getAttribute('href').split('?')[0])) {
      link.classList.add('active');
    }
  });

  // ── Password strength meter ─────────────────────────────────
  document.querySelectorAll('input[type="password"][data-strength]').forEach(function(input) {
    var meter = document.getElementById(input.dataset.strength);
    if (!meter) return;
    input.addEventListener('input', function() {
      var val = input.value;
      var strength = 0;
      if (val.length >= 8) strength++;
      if (/[A-Z]/.test(val)) strength++;
      if (/[0-9]/.test(val)) strength++;
      if (/[@$!%*?&]/.test(val)) strength++;
      meter.className = 'password-strength';
      if (strength <= 1) meter.classList.add('strength-weak');
      else if (strength <= 3) meter.classList.add('strength-medium');
      else meter.classList.add('strength-strong');
    });
  });

  // ── Confirm password match ──────────────────────────────────
  var confirmPwd = document.getElementById('confirmPassword');
  var newPwd = document.getElementById('newPassword') || document.getElementById('password');
  if (confirmPwd && newPwd) {
    confirmPwd.addEventListener('input', function() {
      if (confirmPwd.value !== newPwd.value) {
        confirmPwd.classList.add('is-invalid');
        confirmPwd.classList.remove('is-valid');
      } else {
        confirmPwd.classList.remove('is-invalid');
        confirmPwd.classList.add('is-valid');
      }
    });
  }

  // ── Modal open/close ────────────────────────────────────────
  document.querySelectorAll('[data-modal]').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var modal = document.getElementById(btn.dataset.modal);
      if (modal) modal.classList.add('active');
    });
  });
  document.querySelectorAll('.modal-close, [data-modal-close]').forEach(function(btn) {
    btn.addEventListener('click', function() {
      btn.closest('.modal-overlay').classList.remove('active');
    });
  });
  document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
    overlay.addEventListener('click', function(e) {
      if (e.target === overlay) overlay.classList.remove('active');
    });
  });

  // ── Table search filter ─────────────────────────────────────
  var tableSearch = document.getElementById('tableSearch');
  if (tableSearch) {
    tableSearch.addEventListener('input', function() {
      var q = tableSearch.value.toLowerCase();
      document.querySelectorAll('tbody tr').forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
      });
    });
  }

});

// ── Sidebar toggle (mobile) ──────────────────────────────────
function toggleSidebar() {
  document.querySelector('.sidebar').classList.toggle('open');
}

// ── Password eye toggle ─────────────────────────────────────
function togglePasswordVisibility(btn) {
  var wrapper = btn.closest('.password-wrapper');
  var input = wrapper.querySelector('input');
  var eyeOpen = btn.querySelector('.eye-open');
  var eyeClosed = btn.querySelector('.eye-closed');
  if (input.type === 'password') {
    input.type = 'text';
    eyeOpen.style.display = 'none';
    eyeClosed.style.display = 'block';
    btn.setAttribute('aria-label', 'Hide password');
  } else {
    input.type = 'password';
    eyeOpen.style.display = 'block';
    eyeClosed.style.display = 'none';
    btn.setAttribute('aria-label', 'Show password');
  }
}

// ── Modal helpers ────────────────────────────────────────────
function openModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.add('active');
}
function closeModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.remove('active');
}

// ── Confirm delete ───────────────────────────────────────────
function confirmDelete(url, message) {
  pcConfirm({
    type: 'danger',
    icon: '🗑️',
    title: 'Delete Confirmation',
    message: message || 'This action cannot be undone.',
    confirmText: 'Yes, Delete',
    cancelText: 'Cancel'
  }).then(function(ok) { if (ok) window.location.href = url; });
}

// ── QR Code generation via AJAX ──────────────────────────────
function generateQR(bookId) {
  const container = document.getElementById('qrContainer');
  if (!container) return;
  container.innerHTML = '<div class="spinner"></div>';
  fetch(contextPath + '/qrcode?action=generate&bookId=' + bookId)
    .then(function (r) { return r.json(); })
    .then(function (data) {
      if (data.qr) {
        container.innerHTML = '<img src="data:image/png;base64,' + data.qr + '" alt="QR Code" style="max-width:220px">';
      }
    })
    .catch(function () {
      container.innerHTML = '<p class="text-danger">Failed to generate QR code.</p>';
    });
}

// ── QR Scanner (using jsQR) ──────────────────────────────────
let scannerActive = false;
let scannerStream = null;

function startQRScanner() {
  const video = document.getElementById('qrVideo');
  const canvas = document.getElementById('qrCanvas');
  const result = document.getElementById('qrResult');
  if (!video || !canvas) return;

  scannerActive = true;
  navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
    .then(function (stream) {
      scannerStream = stream;
      video.srcObject = stream;
      video.play();
      requestAnimationFrame(scanFrame);
    })
    .catch(function (err) {
      if (result) result.textContent = 'Camera access denied: ' + err.message;
    });

  function scanFrame() {
    if (!scannerActive) return;
    if (video.readyState === video.HAVE_ENOUGH_DATA) {
      canvas.height = video.videoHeight;
      canvas.width = video.videoWidth;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      const code = jsQR(imageData.data, imageData.width, imageData.height);
      if (code) {
        stopQRScanner();
        handleQRResult(code.data);
        return;
      }
    }
    requestAnimationFrame(scanFrame);
  }
}

function stopQRScanner() {
  scannerActive = false;
  if (scannerStream) {
    scannerStream.getTracks().forEach(function (t) { t.stop(); });
    scannerStream = null;
  }
}

function handleQRResult(data) {
  fetch(contextPath + '/qrcode', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'qrData=' + encodeURIComponent(data)
  })
    .then(function (r) { return r.json(); })
    .then(function (res) {
      const resultDiv = document.getElementById('qrResult');
      if (res.success) {
        if (resultDiv) {
          resultDiv.innerHTML = '<div class="alert alert-success">Book found: <strong>' + res.title + '</strong> (ISBN: ' + res.isbn + ')' +
            (res.available ? ' - <span class="badge badge-success">Available</span>' : ' - <span class="badge badge-danger">Not Available</span>') + '</div>';
        }
        // Auto-fill issue form if present
        const bookSelect = document.getElementById('bookId');
        if (bookSelect) {
          for (let i = 0; i < bookSelect.options.length; i++) {
            if (bookSelect.options[i].value == res.bookId) {
              bookSelect.selectedIndex = i;
              break;
            }
          }
        }
      } else {
        if (resultDiv) resultDiv.innerHTML = '<div class="alert alert-danger">' + res.message + '</div>';
      }
    });
}

// ── Fine calculator ──────────────────────────────────────────
function calculateFine(dueDate, finePerDay, maxFine) {
  const due = new Date(dueDate);
  const now = new Date();
  if (now <= due) return 0;
  const days = Math.floor((now - due) / (1000 * 60 * 60 * 24));
  return Math.min(days * finePerDay, maxFine);
}

// ── Chart helpers (Chart.js) ─────────────────────────────────
function renderBarChart(canvasId, labels, data, label, color) {
  const ctx = document.getElementById(canvasId);
  if (!ctx) return;
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: label,
        data: data,
        backgroundColor: color || 'rgba(44,95,46,0.75)',
        borderColor: color || '#2C5F2E',
        borderWidth: 1,
        borderRadius: 6
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
    }
  });
}

function renderDoughnutChart(canvasId, labels, data) {
  const ctx = document.getElementById(canvasId);
  if (!ctx) return;
  new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [{
        data: data,
        backgroundColor: ['#2C5F2E','#E8A838','#3D7A40','#C8881A','#1E4220','#F0BC5E','#97BC62','#C0392B'],
        borderWidth: 2,
        borderColor: '#fff'
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { position: 'bottom' } }
    }
  });
}

// ── Mobile Sidebar Setup ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function() {
  var sidebar  = document.getElementById('sidebar');
  var topbar   = document.querySelector('.topbar');
  if (!sidebar || !topbar) return;

  // Create overlay
  var overlay = document.createElement('div');
  overlay.className = 'sidebar-overlay';
  overlay.id = 'sidebarOverlay';
  document.body.appendChild(overlay);

  // Create hamburger button and prepend to topbar
  var toggleBtn = document.createElement('button');
  toggleBtn.className = 'sidebar-toggle';
  toggleBtn.setAttribute('aria-label', 'Toggle menu');
  toggleBtn.innerHTML = '☰';
  topbar.insertBefore(toggleBtn, topbar.firstChild);

  // Open sidebar
  toggleBtn.addEventListener('click', function() {
    sidebar.classList.add('open');
    overlay.classList.add('active');
  });

  // Close sidebar when overlay clicked
  overlay.addEventListener('click', function() {
    sidebar.classList.remove('open');
    overlay.classList.remove('active');
  });

  // Close sidebar when a nav link is clicked (mobile)
  sidebar.querySelectorAll('.nav-link').forEach(function(link) {
    link.addEventListener('click', function() {
      if (window.innerWidth <= 768) {
        sidebar.classList.remove('open');
        overlay.classList.remove('active');
      }
    });
  });

  // Close sidebar on resize to desktop
  window.addEventListener('resize', function() {
    if (window.innerWidth > 768) {
      sidebar.classList.remove('open');
      overlay.classList.remove('active');
    }
  });
});
