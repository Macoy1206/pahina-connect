<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Register - Pahina Connect</title>
  <%@ include file="includes/head.jsp" %>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <style>
    .auth-card-wide { max-height:95vh; overflow-y:auto; padding:20px 30px; }
    .auth-header { margin-bottom:15px; }
    .auth-header h1 { font-size:1.5rem; margin:8px 0 4px; }
    .auth-header p { font-size:0.85rem; margin:0; }
    .auth-header .logo-icon { font-size:2rem; }
    .section-divider { font-size:0.85rem; margin:12px 0 8px; padding:4px 0; }
    .form-group { margin-bottom:10px; }
    .form-label { font-size:0.85rem; margin-bottom:4px; }
    .form-control { padding:6px 10px; font-size:0.9rem; }
    .form-control[type="date"] { padding:5px 10px; }
    .form-hint { font-size:0.75rem; margin-top:2px; }
    .form-hint.error { color:var(--danger); }
    .form-hint.success { color:var(--success); }
    .form-control.is-invalid { border-color:var(--danger) !important; }
    .form-control.is-valid   { border-color:var(--success) !important; }
    .password-strength { height:4px; margin-top:4px; border-radius:2px; transition:all 0.3s; }
    .alert { padding:8px 12px; font-size:0.85rem; margin-bottom:10px; }
    .btn-block { margin-top:12px !important; padding:10px; font-size:0.95rem; }
    .auth-footer { padding:12px 0; font-size:0.85rem; }
    textarea.form-control { padding:6px 10px; }
    /* Map modal */
    #mapModal { display:none; position:fixed; inset:0; z-index:9999; background:rgba(0,0,0,0.6); align-items:center; justify-content:center; }
    #mapModal.open { display:flex; }
    #mapModalBox { background:#fff; border-radius:12px; width:90%; max-width:620px; box-shadow:0 8px 32px rgba(0,0,0,0.3); overflow:hidden; }
    #mapModalHeader { background:var(--navy); color:#fff; padding:14px 18px; display:flex; align-items:center; justify-content:space-between; }
    #mapModalHeader h4 { margin:0; font-size:1rem; }
    #mapContainer { height:340px; width:100%; }
    #mapSearchBox { width:100%; padding:7px 12px; border:2px solid var(--navy); border-radius:6px; font-size:0.88rem; box-sizing:border-box; margin-bottom:8px; }
    .map-btn-row { display:flex; gap:8px; }
  </style>
</head>
<body>
<div class="auth-page">
  <div class="auth-card auth-card-wide">
    <div class="auth-header">
      <span class="logo-icon">📚</span>
      <h1>Pahina Connect</h1>
      <p>Create Your Library Account</p>
    </div>
    <div class="auth-body">
      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ ${error}</div>
      </c:if>

      <form method="post" action="${pageContext.request.contextPath}/register" novalidate id="registerForm">

        <div class="section-divider">👤 Personal Information</div>

        <div class="form-row">
          <div class="form-group">
            <label class="form-label">First Name <span class="required">*</span></label>
            <input type="text" name="firstName" id="firstName" class="form-control capitalize-input"
                   placeholder="Juan" required maxlength="100" value="${param.firstName}">
            <span class="form-hint" id="firstNameHint">Letters only, no numbers</span>
          </div>
          <div class="form-group">
            <label class="form-label">Last Name <span class="required">*</span></label>
            <input type="text" name="lastName" id="lastName" class="form-control capitalize-input"
                   placeholder="Dela Cruz" required maxlength="100" value="${param.lastName}">
            <span class="form-hint" id="lastNameHint">Letters only, no numbers</span>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Middle Name <span style="color:var(--text-light);font-weight:400">(optional)</span></label>
          <input type="text" name="middleName" id="middleName" class="form-control capitalize-input"
                 placeholder="Santos" maxlength="100" value="${param.middleName}">
        </div>

        <div class="form-group">
          <label class="form-label">Suffix <span style="color:var(--text-light);font-weight:400">(optional)</span></label>
          <select name="suffix" id="suffix" class="form-control">
            <option value="" ${empty param.suffix ? 'selected' : ''}>None</option>
            <option value="Jr." ${param.suffix eq 'Jr.' ? 'selected' : ''}>Jr. (Junior)</option>
            <option value="Sr." ${param.suffix eq 'Sr.' ? 'selected' : ''}>Sr. (Senior)</option>
            <option value="I"   ${param.suffix eq 'I'   ? 'selected' : ''}>I (The First)</option>
            <option value="II"  ${param.suffix eq 'II'  ? 'selected' : ''}>II (The Second)</option>
            <option value="III" ${param.suffix eq 'III' ? 'selected' : ''}>III (The Third)</option>
            <option value="IV"  ${param.suffix eq 'IV'  ? 'selected' : ''}>IV (The Fourth)</option>
          </select>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Date of Birth <span class="required">*</span></label>
            <input type="date" name="dateOfBirth" id="dateOfBirth" class="form-control"
                   required value="${param.dateOfBirth}">
            <span class="form-hint" id="dobHint">Must be at least 5 years old</span>
          </div>
          <div class="form-group">
            <label class="form-label">Gender <span class="required">*</span></label>
            <select name="gender" id="gender" class="form-control" required>
              <option value="">-- Select --</option>
              <option value="Male"   ${param.gender eq 'Male'   ? 'selected' : ''}>Male</option>
              <option value="Female" ${param.gender eq 'Female' ? 'selected' : ''}>Female</option>
              <option value="Other"  ${param.gender eq 'Other'  ? 'selected' : ''}>Other</option>
            </select>
          </div>
        </div>

        <div class="section-divider">📞 Contact Information</div>

        <div class="form-group">
          <label class="form-label">Email Address <span class="required">*</span></label>
          <input type="email" name="email" id="emailInput" class="form-control"
                 placeholder="juan@gmail.com" required maxlength="150"
                 value="${param.email}" style="width:100%;box-sizing:border-box">
          <span class="form-hint" id="emailHint">⚠️ Only Gmail addresses accepted (e.g. juan@gmail.com)</span>
        </div>

        <div class="form-group">
          <label class="form-label">Phone Number <span class="required">*</span></label>
          <input type="tel" name="phone" id="phoneInput" class="form-control"
                 placeholder="09XXXXXXXXX" required maxlength="20"
                 value="${param.phone}" style="width:100%;box-sizing:border-box">
          <span class="form-hint" id="phoneHint">Format: 09XXXXXXXXX or +639XXXXXXXXX • Max 2 consecutive same digits</span>
        </div>

        <div class="form-group">
          <label class="form-label">Complete Address <span class="required">*</span></label>
          <div style="position:relative">
            <textarea name="address" id="addressField" class="form-control" rows="2"
                      placeholder="House No., Street, Barangay, City, Province" required
                      style="border:2px solid var(--navy);border-radius:8px;padding-right:44px;resize:vertical">${param.address}</textarea>
            <button type="button" id="openMapBtn" title="Pick location on map"
                    style="position:absolute;top:8px;right:8px;background:var(--navy);color:#fff;
                           border:none;border-radius:6px;width:32px;height:32px;cursor:pointer;
                           display:flex;align-items:center;justify-content:center;font-size:1rem;transition:background 0.2s"
                    onmouseover="this.style.background='var(--gold)'"
                    onmouseout="this.style.background='var(--navy)'">📍</button>
          </div>
          <span class="form-hint">Type manually or click 📍 to pick on map</span>
        </div>

        <div class="section-divider">🔒 Account Security</div>

        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Password <span class="required">*</span></label>
            <input type="password" id="password" name="password" class="form-control"
                   placeholder="Min. 8 chars" required>
            <div id="pwdStrength" class="password-strength"></div>
            <span class="form-hint" id="pwdHint">Min 8 chars: uppercase, lowercase, number, special char (@$!%*?&)</span>
          </div>
          <div class="form-group">
            <label class="form-label">Confirm Password <span class="required">*</span></label>
            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                   placeholder="Re-enter password" required>
            <span class="form-hint" id="confirmHint">Must match password above</span>
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block btn-lg">📝 Create Account</button>
      </form>
    </div>
    <div class="auth-footer">
      Already have an account?
      <a href="${pageContext.request.contextPath}/login" style="color:var(--gold);font-weight:600">Login here</a>
    </div>
  </div>
</div>

<!-- Map Modal -->
<div id="mapModal">
  <div id="mapModalBox">
    <div id="mapModalHeader">
      <h4>📍 Pick Your Location</h4>
      <button type="button" id="closeMapBtn" style="background:none;border:none;color:#fff;font-size:1.4rem;cursor:pointer;line-height:1">✕</button>
    </div>
    <div style="padding:10px 14px 6px;background:#f9f9f9;border-bottom:1px solid #eee">
      <input type="text" id="mapSearchBox" placeholder="🔍 Search address or place...">
      <div id="mapSearchResults" style="display:none;background:#fff;border:1px solid #ccc;border-radius:6px;max-height:140px;overflow-y:auto;margin-bottom:6px;font-size:0.83rem"></div>
    </div>
    <div id="mapContainer"></div>
    <div style="padding:12px 16px;background:#f9f9f9;border-top:1px solid #eee">
      <div id="mapAddressPreview" style="font-size:0.85rem;color:var(--navy-dark);font-weight:600;margin-bottom:10px;min-height:20px">📌 Click anywhere on the map to pin your location</div>
      <div class="map-btn-row">
        <button type="button" id="myLocationBtn" class="btn btn-outline btn-sm">📡 My Location</button>
        <button type="button" id="confirmMapBtn" class="btn btn-primary btn-sm" style="flex:1">✅ Use This Address</button>
        <button type="button" id="closeMapBtn2" class="btn btn-outline btn-sm">Cancel</button>
      </div>
    </div>
  </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
// ── Real-time Field Validation ───────────────────────────────────────────────

// Name fields - letters, spaces, hyphens only
function validateName(input, hintId) {
  var val = input.value.trim();
  var hint = document.getElementById(hintId);
  if (!val) { setInvalid(input, hint, 'This field is required'); return false; }
  if (!/^[a-zA-ZÀ-ÿ\s\-\.]+$/.test(val)) { setInvalid(input, hint, 'Letters only, no numbers or special characters'); return false; }
  setValid(input, hint, '✓ Looks good'); return true;
}

// Email - Gmail only
function validateEmail() {
  var input = document.getElementById('emailInput');
  var hint  = document.getElementById('emailHint');
  var val   = input.value.trim().toLowerCase();
  if (!val) { setInvalid(input, hint, 'Email is required'); return false; }
  if (!/^[a-zA-Z0-9._%+\-]+@gmail\.com$/.test(val)) {
    setInvalid(input, hint, '❌ Only Gmail addresses accepted (e.g. juan@gmail.com)');
    return false;
  }
  setValid(input, hint, '✓ Valid Gmail address'); return true;
}

// Phone - Philippine format
function validatePhone() {
  var input = document.getElementById('phoneInput');
  var hint  = document.getElementById('phoneHint');
  var val   = input.value.trim();
  if (!val) { setInvalid(input, hint, 'Phone number is required'); return false; }
  if (!/^(09|\+639)\d{9}$/.test(val)) {
    setInvalid(input, hint, '❌ Format: 09XXXXXXXXX or +639XXXXXXXXX (11 digits)');
    return false;
  }
  // Check for more than 2 consecutive identical digits
  var digits = val.replace(/\D/g, '');
  var count = 1;
  for (var i = 1; i < digits.length; i++) {
    if (digits[i] === digits[i-1]) {
      count++;
      if (count > 2) {
        setInvalid(input, hint, '❌ Phone number cannot have more than 2 consecutive identical digits (e.g. 09192234567 ✓, 09111234567 ✗)');
        return false;
      }
    } else {
      count = 1;
    }
  }
  setValid(input, hint, '✓ Valid Philippine number'); return true;
}

// Date of birth
function validateDOB() {
  var input = document.getElementById('dateOfBirth');
  var hint  = document.getElementById('dobHint');
  var val   = input.value;
  if (!val) { setInvalid(input, hint, 'Date of birth is required'); return false; }
  var dob  = new Date(val);
  var now  = new Date();
  var age  = (now - dob) / (1000 * 60 * 60 * 24 * 365.25);
  if (age < 5)  { setInvalid(input, hint, '❌ Must be at least 5 years old'); return false; }
  if (age > 120){ setInvalid(input, hint, '❌ Invalid date of birth'); return false; }
  setValid(input, hint, '✓ Valid date'); return true;
}

// Password strength
function validatePassword() {
  var input = document.getElementById('password');
  var hint  = document.getElementById('pwdHint');
  var bar   = document.getElementById('pwdStrength');
  var val   = input.value;
  if (!val) { setInvalid(input, hint, 'Password is required'); bar.style.background=''; bar.style.width='0'; return false; }

  var strength = 0;
  var msgs = [];
  if (val.length >= 8)              strength++;  else msgs.push('min 8 chars');
  if (/[A-Z]/.test(val))            strength++;  else msgs.push('uppercase');
  if (/[a-z]/.test(val))            strength++;  else msgs.push('lowercase');
  if (/\d/.test(val))               strength++;  else msgs.push('number');
  if (/[@$!%*?&]/.test(val))        strength++;  else msgs.push('special char (@$!%*?&)');

  var colors = ['', '#e74c3c', '#e67e22', '#f1c40f', '#2ecc71', '#27ae60'];
  var labels = ['', 'Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'];
  bar.style.background = colors[strength];
  bar.style.height = '4px';
  bar.style.width = (strength * 20) + '%';
  bar.style.borderRadius = '2px';

  if (strength < 5) {
    setInvalid(input, hint, '❌ Missing: ' + msgs.join(', '));
    return false;
  }
  setValid(input, hint, '✓ ' + labels[strength] + ' password'); return true;
}

// Confirm password
function validateConfirm() {
  var input = document.getElementById('confirmPassword');
  var hint  = document.getElementById('confirmHint');
  var pwd   = document.getElementById('password').value;
  var val   = input.value;
  if (!val) { setInvalid(input, hint, 'Please confirm your password'); return false; }
  if (val !== pwd) { setInvalid(input, hint, '❌ Passwords do not match'); return false; }
  setValid(input, hint, '✓ Passwords match'); return true;
}

function setInvalid(input, hint, msg) {
  input.classList.add('is-invalid'); input.classList.remove('is-valid');
  if (hint) { hint.textContent = msg; hint.className = 'form-hint error'; }
}
function setValid(input, hint, msg) {
  input.classList.remove('is-invalid'); input.classList.add('is-valid');
  if (hint) { hint.textContent = msg; hint.className = 'form-hint success'; }
}

// Attach listeners
document.getElementById('firstName').addEventListener('blur', function() { validateName(this, 'firstNameHint'); });
document.getElementById('lastName').addEventListener('blur',  function() { validateName(this, 'lastNameHint'); });
document.getElementById('emailInput').addEventListener('blur',    validateEmail);
document.getElementById('emailInput').addEventListener('input',   validateEmail);
document.getElementById('phoneInput').addEventListener('blur',    validatePhone);
document.getElementById('phoneInput').addEventListener('input',   validatePhone);
document.getElementById('dateOfBirth').addEventListener('change', validateDOB);
document.getElementById('password').addEventListener('input',     validatePassword);
document.getElementById('confirmPassword').addEventListener('input', validateConfirm);

// ── Capitalize inputs ────────────────────────────────────────────────────────
document.querySelectorAll('.capitalize-input').forEach(function(input) {
  input.addEventListener('input', function() {
    var pos = this.selectionStart;
    this.value = this.value.replace(/\b\w/g, function(c) { return c.toUpperCase(); });
    this.setSelectionRange(pos, pos);
  });
});

// ── Form Submit Validation ───────────────────────────────────────────────────
document.getElementById('registerForm').addEventListener('submit', function(e) {
  e.preventDefault();

  // Run all validations
  var fn  = validateName(document.getElementById('firstName'), 'firstNameHint');
  var ln  = validateName(document.getElementById('lastName'),  'lastNameHint');
  var dob = validateDOB();
  var gen = document.getElementById('gender').value !== '';
  var em  = validateEmail();
  var ph  = validatePhone();
  var ad  = document.getElementById('addressField').value.trim() !== '';
  var pw  = validatePassword();
  var cp  = validateConfirm();

  if (!gen) {
    document.getElementById('gender').classList.add('is-invalid');
  }
  if (!ad) {
    document.getElementById('addressField').classList.add('is-invalid');
  }

  if (!fn || !ln || !dob || !gen || !em || !ph || !ad || !pw || !cp) {
    Swal.fire({ icon:'error', title:'Please Fix Errors', text:'Please correct all highlighted fields before submitting.', confirmButtonText:'OK' });
    return;
  }

  Swal.fire({
    icon:'question', title:'📝 Confirm Registration',
    html:'Are you sure all information is correct?<br><small>You can update your profile later.</small>',
    showCancelButton:true, confirmButtonText:'Yes, Register',
    cancelButtonText:'Review Again', reverseButtons:true
  }).then(function(result) {
    if (result.isConfirmed) {
      Swal.fire({ title:'Creating Account...', allowOutsideClick:false, didOpen:function(){ Swal.showLoading(); } });
      document.getElementById('registerForm').submit();
    }
  });
});

// ── Map Logic ────────────────────────────────────────────────────────────────
var map, marker, selectedAddress = '';
var mapInitialized = false;

function initMap(lat, lng) {
  if (!mapInitialized) {
    map = L.map('mapContainer').setView([lat, lng], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '© OpenStreetMap contributors', maxZoom: 19 }).addTo(map);
    var pinIcon = L.divIcon({ html: '<div style="font-size:2rem;line-height:1;filter:drop-shadow(0 2px 4px rgba(0,0,0,0.4))">📍</div>', iconSize: [32, 32], iconAnchor: [16, 32], className: '' });
    marker = L.marker([lat, lng], { icon: pinIcon, draggable: true }).addTo(map);
    map.on('click', function(e) { marker.setLatLng(e.latlng); reverseGeocode(e.latlng.lat, e.latlng.lng); });
    marker.on('dragend', function() { var pos = marker.getLatLng(); reverseGeocode(pos.lat, pos.lng); });
    mapInitialized = true;
  } else {
    map.setView([lat, lng], 15); marker.setLatLng([lat, lng]);
  }
  reverseGeocode(lat, lng);
  setTimeout(function() { map.invalidateSize(); }, 200);
}

function reverseGeocode(lat, lng) {
  document.getElementById('mapAddressPreview').textContent = '⏳ Getting address...';
  fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng + '&addressdetails=1')
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data && data.address) {
        var a = data.address, parts = [];
        if (a.house_number) parts.push(a.house_number);
        if (a.road) parts.push(a.road);
        if (a.suburb || a.village || a.neighbourhood) parts.push(a.suburb || a.village || a.neighbourhood);
        if (a.city || a.town || a.municipality || a.county) parts.push(a.city || a.town || a.municipality || a.county);
        if (a.state) parts.push(a.state);
        if (a.postcode) parts.push(a.postcode);
        selectedAddress = parts.filter(Boolean).join(', ') || data.display_name;
      } else { selectedAddress = ''; }
      document.getElementById('mapAddressPreview').textContent = selectedAddress ? '📌 ' + selectedAddress : '📌 Could not get address. Try another spot.';
    })
    .catch(function() { selectedAddress = ''; document.getElementById('mapAddressPreview').textContent = '❌ Could not get address.'; });
}

document.getElementById('openMapBtn').addEventListener('click', function() {
  document.getElementById('mapModal').classList.add('open');
  var defaultLat = 14.5995, defaultLng = 120.9842;
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(pos) { initMap(pos.coords.latitude, pos.coords.longitude); }, function() { initMap(defaultLat, defaultLng); }, { timeout: 5000 });
  } else { initMap(defaultLat, defaultLng); }
});

function closeMap() { document.getElementById('mapModal').classList.remove('open'); }
document.getElementById('closeMapBtn').addEventListener('click', closeMap);
document.getElementById('closeMapBtn2').addEventListener('click', closeMap);
document.getElementById('mapModal').addEventListener('click', function(e) { if (e.target === this) closeMap(); });

document.getElementById('myLocationBtn').addEventListener('click', function() {
  if (!navigator.geolocation) { alert('Geolocation not supported.'); return; }
  var btn = this; btn.textContent = '⏳';
  navigator.geolocation.getCurrentPosition(
    function(pos) { btn.textContent = '📡 My Location'; map.setView([pos.coords.latitude, pos.coords.longitude], 17); marker.setLatLng([pos.coords.latitude, pos.coords.longitude]); reverseGeocode(pos.coords.latitude, pos.coords.longitude); },
    function() { btn.textContent = '📡 My Location'; alert('Could not get your location.'); },
    { timeout: 8000, enableHighAccuracy: true }
  );
});

document.getElementById('confirmMapBtn').addEventListener('click', function() {
  if (selectedAddress) { document.getElementById('addressField').value = selectedAddress; closeMap(); }
  else { alert('Please click on the map to select a location first.'); }
});

var searchTimer;
document.getElementById('mapSearchBox').addEventListener('input', function() {
  clearTimeout(searchTimer);
  var q = this.value.trim(), results = document.getElementById('mapSearchResults');
  if (q.length < 3) { results.style.display = 'none'; return; }
  searchTimer = setTimeout(function() {
    fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(q) + '&limit=5&countrycodes=ph')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        results.innerHTML = '';
        if (!data || data.length === 0) { results.style.display = 'none'; return; }
        data.forEach(function(item) {
          var div = document.createElement('div');
          div.style.cssText = 'padding:8px 12px;cursor:pointer;border-bottom:1px solid #eee';
          div.textContent = item.display_name;
          div.onmouseenter = function() { this.style.background = '#f0f0f0'; };
          div.onmouseleave = function() { this.style.background = ''; };
          div.addEventListener('click', function() {
            var lat = parseFloat(item.lat), lng = parseFloat(item.lon);
            map.setView([lat, lng], 16); marker.setLatLng([lat, lng]); reverseGeocode(lat, lng);
            results.style.display = 'none'; document.getElementById('mapSearchBox').value = '';
          });
          results.appendChild(div);
        });
        results.style.display = 'block';
      });
  }, 400);
});
</script>
</body>
</html>
