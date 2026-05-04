<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>My Profile - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <style>
    .avatar-upload { position:relative; display:inline-block; cursor:pointer; }
    .avatar-upload img, .avatar-upload .avatar-placeholder {
      width:110px; height:110px; border-radius:50%;
      object-fit:cover; border:4px solid var(--green);
      box-shadow:0 4px 16px rgba(44,95,46,0.2);
    }
    .avatar-placeholder {
      background:var(--green); display:flex; align-items:center;
      justify-content:center; font-size:2.5rem; color:white; font-weight:700;
    }
    .avatar-overlay {
      position:absolute; inset:0; border-radius:50%;
      background:rgba(44,95,46,0.7); display:flex; align-items:center;
      justify-content:center; opacity:0; transition:0.2s;
      color:white; font-size:1.5rem;
    }
    .avatar-upload:hover .avatar-overlay { opacity:1; }

    /* Map modal */
    #mapModal {
      display:none; position:fixed; inset:0; z-index:9999;
      background:rgba(0,0,0,0.6); align-items:center; justify-content:center;
    }
    #mapModal.open { display:flex; }
    #mapModalBox {
      background:#fff; border-radius:12px; width:90%; max-width:620px;
      box-shadow:0 8px 32px rgba(0,0,0,0.3); overflow:hidden;
    }
    #mapModalHeader {
      background:var(--navy); color:#fff; padding:14px 18px;
      display:flex; align-items:center; justify-content:space-between;
    }
    #mapModalHeader h4 { margin:0; font-size:1rem; }
    #mapContainer { height:340px; width:100%; }
    #mapSearchBox {
      width:100%; padding:7px 12px; border:2px solid var(--navy);
      border-radius:6px; font-size:0.88rem; box-sizing:border-box;
    }
    .map-btn-row { display:flex; gap:8px; margin-top:8px; }
  </style>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/student-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar"><span class="topbar-title">👤 My Profile</span></div>
    <div class="page-content-centered">
      <div class="form-container" style="max-width:600px;width:100%">
        <%@ include file="../includes/alerts.jsp" %>
        <div class="form-card">
          <div class="form-card-header">
            <h3>👤 Update Personal Information</h3>
            <p>Keep your profile information up to date</p>
          </div>
          <div class="form-card-body">

            <!-- Student ID -->
            <div class="student-id-box">
              <div class="id-icon">🎓</div>
              <div>
                <p class="id-label">Your Student ID</p>
                <p class="id-value">${sessionScope.loggedUser.studentId}</p>
              </div>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/student/profile"
                  enctype="multipart/form-data" novalidate
                  data-confirm="Your profile information will be updated."
                  data-confirm-title="Update Profile?"
                  data-confirm-type="info"
                  data-confirm-icon="💾"
                  data-confirm-ok="Yes, Update"
                  data-confirm-cancel="Cancel">

              <!-- Profile Picture -->
              <div class="form-group text-center" style="margin-bottom:28px">
                <label class="form-label" style="display:block;margin-bottom:12px">Profile Picture</label>
                <label class="avatar-upload" for="profilePicInput" title="Click to change photo">
                  <c:choose>
                    <c:when test="${not empty sessionScope.loggedUser.profilePicture}">
                      <img id="avatarPreview"
                           src="${pageContext.request.contextPath}/uploads/profiles/${sessionScope.loggedUser.profilePicture}"
                           alt="Profile">
                    </c:when>
                    <c:otherwise>
                      <div class="avatar-placeholder" id="avatarPlaceholder">
                        ${sessionScope.loggedUser.firstName.charAt(0)}${sessionScope.loggedUser.lastName.charAt(0)}
                      </div>
                    </c:otherwise>
                  </c:choose>
                  <div class="avatar-overlay">📷</div>
                </label>
                <input type="file" id="profilePicInput" name="profilePicture"
                       accept="image/*" style="display:none"
                       onchange="previewAvatar(this)">
                <p style="margin:8px 0 0;font-size:0.78rem;color:var(--text-light)">
                  Click photo to change • JPG, PNG, GIF (max 5MB)
                </p>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">First Name <span class="required">*</span></label>
                  <input type="text" name="firstName" class="form-control capitalize-input" required maxlength="100"
                         value="${sessionScope.loggedUser.firstName}">
                </div>
                <div class="form-group">
                  <label class="form-label">Last Name <span class="required">*</span></label>
                  <input type="text" name="lastName" class="form-control capitalize-input" required maxlength="100"
                         value="${sessionScope.loggedUser.lastName}">
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">Middle Name</label>
                <input type="text" name="middleName" class="form-control capitalize-input" maxlength="100"
                       value="${sessionScope.loggedUser.middleName}">
              </div>
              <div class="form-group">
                <label class="form-label">Suffix <span style="color:var(--text-light);font-weight:400">(optional)</span></label>
                <select name="suffix" class="form-control">
                  <option value="" ${empty sessionScope.loggedUser.suffix ? 'selected' : ''}>None</option>
                  <option value="Jr." ${sessionScope.loggedUser.suffix eq 'Jr.' ? 'selected' : ''}>Jr. (Junior)</option>
                  <option value="Sr." ${sessionScope.loggedUser.suffix eq 'Sr.' ? 'selected' : ''}>Sr. (Senior)</option>
                  <option value="I"   ${sessionScope.loggedUser.suffix eq 'I'   ? 'selected' : ''}>I (The First)</option>
                  <option value="II"  ${sessionScope.loggedUser.suffix eq 'II'  ? 'selected' : ''}>II (The Second)</option>
                  <option value="III" ${sessionScope.loggedUser.suffix eq 'III' ? 'selected' : ''}>III (The Third)</option>
                  <option value="IV"  ${sessionScope.loggedUser.suffix eq 'IV'  ? 'selected' : ''}>IV (The Fourth)</option>
                </select>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Date of Birth</label>
                  <input type="date" name="dateOfBirth" class="form-control"
                         value="<fmt:formatDate value='${sessionScope.loggedUser.dateOfBirth}' pattern='yyyy-MM-dd'/>">
                </div>
                <div class="form-group">
                  <label class="form-label">Gender</label>
                  <select name="gender" class="form-control">
                    <option value="">-- Select --</option>
                    <option value="Male"   ${sessionScope.loggedUser.gender eq 'Male'   ? 'selected' : ''}>Male</option>
                    <option value="Female" ${sessionScope.loggedUser.gender eq 'Female' ? 'selected' : ''}>Female</option>
                    <option value="Other"  ${sessionScope.loggedUser.gender eq 'Other'  ? 'selected' : ''}>Other</option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" class="form-control" value="${sessionScope.loggedUser.email}" disabled
                       style="background:var(--cream);cursor:not-allowed">
                <span class="form-hint">Email cannot be changed. Contact admin if needed.</span>
              </div>
              <div class="form-group">
                <label class="form-label">Phone Number <span class="required">*</span></label>
                <input type="tel" name="phone" class="form-control" required maxlength="20"
                       placeholder="09XXXXXXXXX" value="${sessionScope.loggedUser.phone}">
              </div>

              <!-- Address with Map -->
              <div class="form-group">
                <label class="form-label">Complete Address <span class="required">*</span></label>
                <div style="position:relative">
                  <textarea name="address" id="addressField" class="form-control" rows="3" required
                            style="border:2px solid var(--navy);border-radius:8px;padding-right:44px;resize:vertical">${sessionScope.loggedUser.address}</textarea>
                  <button type="button" id="openMapBtn"
                          title="Pick location on map"
                          style="position:absolute;top:8px;right:8px;background:var(--navy);color:#fff;
                                 border:none;border-radius:6px;width:32px;height:32px;cursor:pointer;
                                 display:flex;align-items:center;justify-content:center;font-size:1rem;
                                 transition:background 0.2s"
                          onmouseover="this.style.background='var(--gold)'"
                          onmouseout="this.style.background='var(--navy)'">📍</button>
                </div>
                <span class="form-hint">Type manually or click 📍 to pick on map</span>
              </div>

              <button type="submit" class="btn btn-primary btn-block">💾 Update Profile</button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ── Map Modal ─────────────────────────────────────────────────────────── -->
<div id="mapModal">
  <div id="mapModalBox">
    <div id="mapModalHeader">
      <h4>📍 Pick Your Location</h4>
      <button type="button" id="closeMapBtn"
              style="background:none;border:none;color:#fff;font-size:1.4rem;cursor:pointer;line-height:1">✕</button>
    </div>
    <div style="padding:10px 14px 6px;background:#f9f9f9;border-bottom:1px solid #eee">
      <input type="text" id="mapSearchBox" placeholder="🔍 Search address or place...">
      <div id="mapSearchResults"
           style="display:none;background:#fff;border:1px solid #ccc;border-radius:6px;
                  max-height:130px;overflow-y:auto;margin-top:4px;font-size:0.83rem"></div>
    </div>
    <div id="mapContainer"></div>
    <div style="padding:12px 16px;background:#f9f9f9;border-top:1px solid #eee">
      <div id="mapAddressPreview"
           style="font-size:0.85rem;color:var(--navy-dark);font-weight:600;margin-bottom:10px;min-height:20px">
        📌 Click anywhere on the map to pin your location
      </div>
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
// ── Avatar Preview ───────────────────────────────────────────────────────────
function previewAvatar(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function(e) {
      var existing = document.getElementById('avatarPreview');
      var placeholder = document.getElementById('avatarPlaceholder');
      if (existing) {
        existing.src = e.target.result;
      } else if (placeholder) {
        var img = document.createElement('img');
        img.id = 'avatarPreview'; img.src = e.target.result; img.alt = 'Profile';
        img.style.cssText = 'width:110px;height:110px;border-radius:50%;object-fit:cover;border:4px solid var(--green)';
        placeholder.parentNode.replaceChild(img, placeholder);
      }
    };
    reader.readAsDataURL(input.files[0]);
  }
}

// ── Capitalize inputs ────────────────────────────────────────────────────────
document.querySelectorAll('.capitalize-input').forEach(function(input) {
  input.addEventListener('input', function() {
    var pos = this.selectionStart;
    this.value = this.value.replace(/\b\w/g, function(c) { return c.toUpperCase(); });
    this.setSelectionRange(pos, pos);
  });
});

// ── Map Logic ────────────────────────────────────────────────────────────────
var map, marker, selectedAddress = '';
var mapInitialized = false;

function initMap(lat, lng) {
  if (!mapInitialized) {
    map = L.map('mapContainer').setView([lat, lng], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors', maxZoom: 19
    }).addTo(map);

    var pinIcon = L.divIcon({
      html: '<div style="font-size:2rem;line-height:1;filter:drop-shadow(0 2px 4px rgba(0,0,0,0.4))">📍</div>',
      iconSize: [32, 32], iconAnchor: [16, 32], className: ''
    });

    marker = L.marker([lat, lng], { icon: pinIcon, draggable: true }).addTo(map);

    map.on('click', function(e) {
      marker.setLatLng(e.latlng);
      reverseGeocode(e.latlng.lat, e.latlng.lng);
    });

    marker.on('dragend', function() {
      var pos = marker.getLatLng();
      reverseGeocode(pos.lat, pos.lng);
    });

    mapInitialized = true;
  } else {
    map.setView([lat, lng], 15);
    marker.setLatLng([lat, lng]);
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
        var a = data.address;
        var parts = [];
        if (a.house_number) parts.push(a.house_number);
        if (a.road)         parts.push(a.road);
        if (a.suburb || a.village || a.neighbourhood)
          parts.push(a.suburb || a.village || a.neighbourhood);
        if (a.city || a.town || a.municipality || a.county)
          parts.push(a.city || a.town || a.municipality || a.county);
        if (a.state)    parts.push(a.state);
        if (a.postcode) parts.push(a.postcode);
        selectedAddress = parts.filter(Boolean).join(', ') || data.display_name;
      } else {
        selectedAddress = '';
      }
      document.getElementById('mapAddressPreview').textContent =
        selectedAddress ? '📌 ' + selectedAddress : '📌 Could not get address. Try another spot.';
    })
    .catch(function() {
      selectedAddress = '';
      document.getElementById('mapAddressPreview').textContent = '❌ Could not get address.';
    });
}

// Open map
document.getElementById('openMapBtn').addEventListener('click', function() {
  document.getElementById('mapModal').classList.add('open');
  var defaultLat = 14.5995, defaultLng = 120.9842;
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      function(pos) { initMap(pos.coords.latitude, pos.coords.longitude); },
      function()    { initMap(defaultLat, defaultLng); },
      { timeout: 5000 }
    );
  } else {
    initMap(defaultLat, defaultLng);
  }
});

// Close map
function closeMap() { document.getElementById('mapModal').classList.remove('open'); }
document.getElementById('closeMapBtn').addEventListener('click', closeMap);
document.getElementById('closeMapBtn2').addEventListener('click', closeMap);
document.getElementById('mapModal').addEventListener('click', function(e) {
  if (e.target === this) closeMap();
});

// My Location
document.getElementById('myLocationBtn').addEventListener('click', function() {
  if (!navigator.geolocation) { alert('Geolocation not supported.'); return; }
  var btn = this;
  btn.textContent = '⏳';
  navigator.geolocation.getCurrentPosition(
    function(pos) {
      btn.textContent = '📡 My Location';
      map.setView([pos.coords.latitude, pos.coords.longitude], 17);
      marker.setLatLng([pos.coords.latitude, pos.coords.longitude]);
      reverseGeocode(pos.coords.latitude, pos.coords.longitude);
    },
    function() { btn.textContent = '📡 My Location'; alert('Could not get your location.'); },
    { timeout: 8000, enableHighAccuracy: true }
  );
});

// Confirm address
document.getElementById('confirmMapBtn').addEventListener('click', function() {
  if (selectedAddress) {
    document.getElementById('addressField').value = selectedAddress;
    closeMap();
  } else {
    alert('Please click on the map to select a location first.');
  }
});

// Map search
var searchTimer;
document.getElementById('mapSearchBox').addEventListener('input', function() {
  clearTimeout(searchTimer);
  var q = this.value.trim();
  var results = document.getElementById('mapSearchResults');
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
            map.setView([lat, lng], 16);
            marker.setLatLng([lat, lng]);
            reverseGeocode(lat, lng);
            results.style.display = 'none';
            document.getElementById('mapSearchBox').value = '';
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
