<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Search Books - Pahina Connect</title>
  <%@ include file="includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <c:choose>
    <c:when test="${sessionScope.loggedUser.role eq 'admin'}">
      <%@ include file="includes/admin-sidebar.jsp" %>
    </c:when>
    <c:otherwise>
      <%@ include file="includes/student-sidebar.jsp" %>
    </c:otherwise>
  </c:choose>

  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">🔍 Browse & Search Books</span>
    </div>
    <div class="page-content">
      <%@ include file="includes/alerts.jsp" %>

      <!-- Search Filters -->
      <form method="get" action="${pageContext.request.contextPath}/search" class="card mb-3">
        <div class="card-header"><h3>🔍 Search & Filter</h3></div>
        <div class="card-body" style="padding:20px 24px">
          <!-- Row 1: Search -->
          <div style="margin-bottom:14px">
            <label class="form-label">Search (Title / ISBN / Author)</label>
            <div style="position:relative;max-width:400px">
              <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text-light);pointer-events:none">🔍</span>
              <input type="text" name="q" id="searchInput" class="form-control"
                     placeholder="Enter keywords or ISBN..." value="${query}"
                     autocomplete="off" style="padding-left:38px">
            </div>
          </div>
          <!-- Row 2: Category + Author + Available -->
          <div style="display:flex;gap:20px;align-items:flex-end;flex-wrap:wrap;margin-bottom:14px">
            <div class="form-group" style="margin-bottom:0;min-width:180px;flex:1">
              <label class="form-label">Category</label>
              <select id="categoryFilter" name="category" class="form-control">
                <option value="">All Categories</option>
                <c:forEach var="cat" items="${categories}">
                  <option value="${cat.id}" ${selectedCategory eq cat.id ? 'selected' : ''}>${cat.name}</option>
                </c:forEach>
              </select>
            </div>
            <div class="form-group" style="margin-bottom:0;min-width:180px;flex:1">
              <label class="form-label">Author</label>
              <select id="authorFilter" name="author" class="form-control">
                <option value="">All Authors</option>
                <c:forEach var="a" items="${authors}">
                  <option value="${a.id}" ${selectedAuthor eq a.id ? 'selected' : ''}>${a.fullName}</option>
                </c:forEach>
              </select>
            </div>
            <div style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;padding-bottom:2px">
              <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:0.9rem;white-space:nowrap">
                <input type="checkbox" id="availableFilter" name="available" value="1" ${availableOnly eq '1' ? 'checked' : ''}
                       style="width:16px;height:16px">
                Available books only
              </label>
            </div>
          </div>
        </div>
      </form>

      <!-- Results -->
      <div class="card">
        <div class="card-header">
          <h3>📚 Books (<span id="bookCount">${books.size()}</span> found)</h3>
          <span style="color:rgba(255,255,255,0.7);font-size:0.85rem">Click a book to see details</span>
        </div>
        <div class="card-body" style="padding:16px">
          <!-- Book grid — filtered live by JS -->
          <div id="bookGrid" style="display:grid;grid-template-columns:repeat(6,1fr);gap:12px">
            <c:forEach var="book" items="${books}">
              <div class="book-card-item"
                   data-title="${book.title.toLowerCase()}"
                   data-author="${book.authorName.toLowerCase()}"
                   data-isbn="${book.isbn}"
                   data-category-id="${book.categoryId}"
                   data-author-id="${book.authorId}"
                   data-available="${book.availableCopies}"
                   onclick="showBookDetail(
                    ${book.id},
                    '${book.title.replace("'","\\'")}',
                    '${book.authorName.replace("'","\\'")}',
                    '${book.categoryName}',
                    '${book.isbn}',
                    ${book.availableCopies},
                    ${book.totalCopies},
                    '${book.location}',
                    '${book.language}',
                    ${book.pages},
                    '${book.description.replace("'","\\'").replace('"','&quot;')}',
                    '${not empty book.ebookFile ? book.ebookFile : ""}',
                    '${not empty book.qrCode ? book.qrCode : ""}'
                  )"
                  style="cursor:pointer;border-radius:8px;overflow:hidden;border:1px solid var(--cream-dark);background:#fff;box-shadow:0 2px 6px rgba(27,58,107,0.08);transition:all 0.2s"
                  onmouseover="this.style.transform='translateY(-3px)';this.style.boxShadow='0 6px 18px rgba(27,58,107,0.18)'"
                  onmouseout="this.style.transform='';this.style.boxShadow='0 2px 6px rgba(27,58,107,0.08)'">
                <div style="height:110px;background:linear-gradient(135deg,var(--cream-dark),var(--cream-darker));display:flex;align-items:center;justify-content:center;overflow:hidden;position:relative">
                  <c:choose>
                    <c:when test="${not empty book.coverImage}">
                      <img src="${book.coverImage}" alt="${book.title}" style="width:100%;height:100%;object-fit:cover" onerror="this.style.display='none';this.nextElementSibling.style.display='block'">
                      <span style="font-size:2.5rem;display:none">📖</span>
                    </c:when>
                    <c:otherwise><span style="font-size:2.5rem">📖</span></c:otherwise>
                  </c:choose>
                  <div style="position:absolute;top:5px;right:5px">
                    <c:choose>
                      <c:when test="${book.availableCopies gt 0}">
                        <span style="background:var(--success);color:#fff;font-size:0.62rem;font-weight:700;padding:2px 5px;border-radius:4px">${book.availableCopies} avail</span>
                      </c:when>
                      <c:otherwise>
                        <span style="background:var(--danger);color:#fff;font-size:0.62rem;font-weight:700;padding:2px 5px;border-radius:4px">Unavail</span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
                <div style="padding:7px 8px">
                  <div style="font-size:0.75rem;font-weight:700;color:var(--navy-dark);line-height:1.3;margin-bottom:2px;overflow:hidden;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical">${book.title}</div>
                  <div style="font-size:0.68rem;color:var(--text-light);overflow:hidden;white-space:nowrap;text-overflow:ellipsis">${book.authorName}</div>
                </div>
              </div>
            </c:forEach>
          </div>
          <div id="noResults" style="display:none;padding:60px 20px;text-align:center;color:var(--text-light)">
            <span style="font-size:4rem">📚</span>
            <p style="margin-top:16px;font-size:1.1rem">No books match your search.</p>
          </div>
          <c:if test="${empty books}">
            <div class="text-center text-muted" style="padding:60px 20px">
              <span style="font-size:4rem">📚</span>
              <p style="margin-top:16px;font-size:1.1rem">No books found.</p>
              <a href="${pageContext.request.contextPath}/search" class="btn btn-outline mt-2">Show All Books</a>
            </div>
          </c:if>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Borrow Request Form Modal -->
<div class="modal-overlay" id="borrowFormModal" style="z-index:10000">
  <div class="modal" style="max-width:520px;z-index:10001">
    <div class="modal-header" style="background:var(--green)">
      <h3 style="color:white">📥 Book Borrow Request Form</h3>
      <button class="modal-close" data-modal-close>✕</button>
    </div>
    <div class="modal-body">
      <!-- Book info -->
      <div style="background:var(--cream);border-left:4px solid var(--navy);padding:14px;border-radius:var(--radius-sm);margin-bottom:16px">
        <p style="margin:0;font-size:0.82rem;color:var(--text-light)">Book to Borrow</p>
        <p id="borrowBookTitle" style="margin:4px 0 0;font-size:1rem;font-weight:700;color:var(--navy-dark)"></p>
      </div>

      <!-- Borrow slot indicator -->
      <div id="borrowSlotInfo" style="background:var(--info-light);border:1px solid var(--navy);border-radius:var(--radius-sm);padding:12px 16px;margin-bottom:16px;font-size:0.88rem;color:var(--navy-dark)">
        📚 Loading borrow limit info...
      </div>

      <!-- Terms -->
      <div style="background:#FBF5E8;border:1px solid var(--gold);border-radius:var(--radius-sm);padding:14px;margin-bottom:16px">
        <p style="margin:0 0 8px;font-weight:700;color:var(--navy-dark);font-size:0.88rem">📋 Borrowing Terms</p>
        <table style="width:100%;font-size:0.83rem;border-collapse:collapse">
          <tr style="border-bottom:1px solid rgba(200,169,110,0.3)">
            <td style="padding:5px 0;color:var(--text-light)">Max Books at a Time</td>
            <td style="font-weight:600;color:var(--navy-dark)">3 different titles</td>
          </tr>
          <tr style="border-bottom:1px solid rgba(200,169,110,0.3)">
            <td style="padding:5px 0;color:var(--text-light)">Copies per Title</td>
            <td style="font-weight:600;color:var(--navy-dark)">1 copy only</td>
          </tr>
          <tr style="border-bottom:1px solid rgba(200,169,110,0.3)">
            <td style="padding:5px 0;color:var(--text-light)">Your Return Date</td>
            <td id="borrowDueDate" style="font-weight:600;color:var(--danger)"></td>
          </tr>
          <tr style="border-bottom:1px solid rgba(200,169,110,0.3)">
            <td style="padding:5px 0;color:var(--text-light)">Late Fine</td>
            <td style="font-weight:600;color:var(--danger)">₱5.00 per day</td>
          </tr>
          <tr>
            <td style="padding:5px 0;color:var(--text-light)">Maximum Fine</td>
            <td style="font-weight:600;color:var(--danger)">₱500.00</td>
          </tr>
        </table>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/borrow-request">
        <input type="hidden" name="action" value="request">
        <input type="hidden" name="bookId" id="borrowBookId">

        <div class="form-group">
          <label class="form-label">Preferred Return Date <span class="required">*</span></label>
          <input type="date" name="preferredReturnDate" id="borrowReturnDate" class="form-control" required>
          <span class="form-hint">Choose when you plan to return the book (max 30 days from today).</span>
        </div>

        <div class="form-group">
          <label class="form-label">Purpose / Notes <span style="color:var(--text-light);font-weight:400">(optional)</span></label>
          <textarea name="notes" class="form-control" rows="2"
                    placeholder="e.g. For school research, personal reading..."></textarea>
        </div>

        <!-- Agreement checkbox -->
        <div style="background:var(--cream);border-radius:var(--radius-sm);padding:12px 14px;margin-bottom:16px">
          <label style="display:flex;align-items:flex-start;gap:10px;cursor:pointer;font-size:0.88rem;color:var(--text-dark)">
            <input type="checkbox" id="agreeTerms" style="width:16px;height:16px;margin-top:2px;flex-shrink:0" required>
            <span>I agree to return this book on my chosen date and understand that a fine of
            <strong>₱5.00 per day</strong> will be charged for late returns.</span>
          </label>
        </div>

        <div class="modal-footer" style="padding:0;border:none">
          <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
          <button type="submit" id="submitBorrowBtn" class="btn btn-primary">📥 Submit Borrow Request</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Book Detail Modal -->
<div class="modal-overlay" id="bookDetailModal">
  <div class="modal" style="max-width:680px">
    <div class="modal-header">
      <h3 id="modalBookTitle">Book Details</h3>
      <button class="modal-close" data-modal-close>✕</button>
    </div>
    <div class="modal-body">
      <div class="grid grid-2" style="gap:20px">
        <!-- Left: Info -->
        <div>
          <table style="width:100%;font-size:0.88rem;border-collapse:collapse">
            <tr style="border-bottom:1px solid var(--cream-dark)">
              <td style="padding:7px 0;color:var(--text-light);width:40%">Author</td>
              <td id="modalAuthor" style="font-weight:600"></td>
            </tr>
            <tr style="border-bottom:1px solid var(--cream-dark)">
              <td style="padding:7px 0;color:var(--text-light)">Category</td>
              <td id="modalCategory"></td>
            </tr>
            <tr style="border-bottom:1px solid var(--cream-dark)">
              <td style="padding:7px 0;color:var(--text-light)">ISBN</td>
              <td><code id="modalIsbn"></code></td>
            </tr>
            <tr style="border-bottom:1px solid var(--cream-dark)">
              <td style="padding:7px 0;color:var(--text-light)">Location</td>
              <td id="modalLocation"></td>
            </tr>
            <tr style="border-bottom:1px solid var(--cream-dark)">
              <td style="padding:7px 0;color:var(--text-light)">Language</td>
              <td id="modalLanguage"></td>
            </tr>
            <tr style="border-bottom:1px solid var(--cream-dark)">
              <td style="padding:7px 0;color:var(--text-light)">Pages</td>
              <td id="modalPages"></td>
            </tr>
            <tr>
              <td style="padding:7px 0;color:var(--text-light)">Availability</td>
              <td id="modalAvailability"></td>
            </tr>
          </table>
          <div id="modalDescription" style="margin-top:14px;font-size:0.85rem;color:var(--text-mid);line-height:1.6;padding:12px;background:var(--cream);border-radius:var(--radius-sm)"></div>

          <!-- Action buttons -->
          <div id="modalActions" style="margin-top:16px;display:flex;gap:8px;flex-wrap:wrap"></div>
        </div>

        <!-- Right: QR Code -->
        <div style="text-align:center">
          <div id="bookQRSection">
            <p style="font-size:0.85rem;color:var(--text-light);margin-bottom:10px">📱 Book QR Code</p>
            <div id="bookQRContainer" style="background:var(--cream);border-radius:var(--radius);padding:16px;display:inline-block">
              <div class="spinner"></div>
            </div>
            <p style="font-size:0.75rem;color:var(--text-light);margin-top:8px">Scan to open Pahina Connect website</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
var currentBookId = null;

function showBorrowForm(id, title) {
  // Close book detail modal first, then open borrow form on top
  closeModal('bookDetailModal');

  document.getElementById('borrowBookId').value = id;
  document.getElementById('borrowBookTitle').textContent = title;

  // Set date picker: min = tomorrow, max = 30 days, default = 14 days
  var today = new Date();
  var tomorrow = new Date(today); tomorrow.setDate(today.getDate() + 1);
  var maxDate  = new Date(today); maxDate.setDate(today.getDate() + 30);
  var defDate  = new Date(today); defDate.setDate(today.getDate() + 14);

  function fmt(d) {
    return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
  }
  var dateInput = document.getElementById('borrowReturnDate');
  dateInput.min   = fmt(tomorrow);
  dateInput.max   = fmt(maxDate);
  dateInput.value = fmt(defDate);

  document.getElementById('borrowDueDate').textContent = defDate.toLocaleDateString('en-PH', {year:'numeric',month:'long',day:'numeric'});

  dateInput.onchange = function() {
    if (this.value) {
      var d = new Date(this.value + 'T00:00:00');
      document.getElementById('borrowDueDate').textContent = d.toLocaleDateString('en-PH', {year:'numeric',month:'long',day:'numeric'});
    }
  };

  // Fetch borrow slot info
  var slotInfo = document.getElementById('borrowSlotInfo');
  var submitBtn = document.getElementById('submitBorrowBtn');
  slotInfo.innerHTML = '⏳ Checking your borrow limit...';
  submitBtn.disabled = true;

  fetch(contextPath + '/borrow-request?action=checkLimit')
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var used  = data.used  || 0;
      var limit = data.limit || 3;
      var slots = limit - used;
      if (slots <= 0) {
        slotInfo.style.background = '#FDECEA';
        slotInfo.style.borderColor = 'var(--danger)';
        slotInfo.style.color = 'var(--danger)';
        slotInfo.innerHTML = '🚫 You have reached the maximum of <strong>' + limit + ' books</strong>. Please return a book first before borrowing another.';
        submitBtn.disabled = true;
      } else {
        slotInfo.style.background = 'var(--info-light)';
        slotInfo.style.borderColor = 'var(--navy)';
        slotInfo.style.color = 'var(--navy-dark)';
        slotInfo.innerHTML = '📚 You currently have <strong>' + used + ' / ' + limit + '</strong> books borrowed or pending. You can still borrow <strong>' + slots + ' more</strong>.';
        submitBtn.disabled = false;
      }
    })
    .catch(function() {
      slotInfo.innerHTML = '📚 Max 3 different book titles at a time. 1 copy per title only.';
      submitBtn.disabled = false;
    });

  openModal('borrowFormModal');
}

function showBookDetail(id, title, author, category, isbn, available, total, location, language, pages, description, ebookFile, qrCode) {
  currentBookId = id;

  document.getElementById('modalBookTitle').textContent = title;
  document.getElementById('modalAuthor').textContent = author;
  document.getElementById('modalCategory').textContent = category;
  document.getElementById('modalIsbn').textContent = isbn;
  document.getElementById('modalLocation').textContent = location;
  document.getElementById('modalLanguage').textContent = language;
  document.getElementById('modalPages').textContent = pages + ' pages';
  document.getElementById('modalDescription').textContent = description;

  // Availability
  var availEl = document.getElementById('modalAvailability');
  if (available > 0) {
    availEl.innerHTML = '<span class="badge badge-success">' + available + ' / ' + total + ' available</span>';
  } else {
    availEl.innerHTML = '<span class="badge badge-danger">Not available (0/' + total + ')</span>';
  }

  // Action buttons
  var actions = document.getElementById('modalActions');
  actions.innerHTML = '';

  var role = '${sessionScope.loggedUser.role}';

  if (ebookFile) {
    var ebookBtn = document.createElement('a');
    ebookBtn.href = contextPath + '/ebook?action=view&bookId=' + id;
    ebookBtn.className = 'btn btn-gold';
    ebookBtn.innerHTML = '📄 Read E-Book';
    actions.appendChild(ebookBtn);
  }

  if (role === 'student') {
    if (available > 0) {
      var borrowBtn = document.createElement('button');
      borrowBtn.className = 'btn btn-primary';
      borrowBtn.innerHTML = '📥 Request to Borrow';
      borrowBtn.onclick = function() {
        showBorrowForm(id, title);
      };
      actions.appendChild(borrowBtn);
    } else {
      var reserveForm = document.createElement('form');
      reserveForm.method = 'post';
      reserveForm.action = contextPath + '/reserve';
      reserveForm.style.display = 'inline';
      reserveForm.innerHTML = '<input type="hidden" name="action" value="reserve">' +
        '<input type="hidden" name="bookId" value="' + id + '">' +
        '<button type="submit" class="btn btn-outline">🔖 Reserve</button>';
      actions.appendChild(reserveForm);
    }
  }

  // Load book QR code
  var bookQR = document.getElementById('bookQRContainer');
  bookQR.innerHTML = '<div class="spinner"></div>';
  fetch(contextPath + '/qrcode?action=generate&bookId=' + id)
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.qr) {
        bookQR.innerHTML = '<img src="data:image/png;base64,' + data.qr + '" style="width:180px;height:180px" alt="Book QR">';
      }
    })
    .catch(function() {
      // Try static file
      bookQR.innerHTML = '<img src="' + contextPath + '/uploads/qrcodes/qr_' + id + '.png" style="width:180px;height:180px" onerror="this.parentElement.innerHTML=\'<p style=color:var(--text-light)>QR not available</p>\'" alt="Book QR">';
    });

  // E-book QR code - removed, only book QR code is shown
  var ebookSection = document.getElementById('ebookQRSection');
  if (ebookSection) ebookSection.style.display = 'none';

  openModal('bookDetailModal');
}// ── Live search filter ──────────────────────────────────────
var searchInput     = document.getElementById('searchInput');
var categoryFilter  = document.getElementById('categoryFilter');
var authorFilter    = document.getElementById('authorFilter');
var availableFilter = document.getElementById('availableFilter');
var allCards        = document.querySelectorAll('.book-card-item');
var noResults       = document.getElementById('noResults');
var bookGrid        = document.getElementById('bookGrid');
var bookCount       = document.getElementById('bookCount');
var totalBooks      = allCards.length;

function wordStartMatch(text, q) {
  var words = text.split(/[\s\-_:]+/);
  for (var i = 0; i < words.length; i++) {
    if (words[i].indexOf(q) === 0) return true;
  }
  return false;
}

function applyFilters() {
  var q         = searchInput     ? searchInput.value.toLowerCase().trim()  : '';
  var catId     = categoryFilter  ? categoryFilter.value                    : '';
  var authId    = authorFilter    ? authorFilter.value                      : '';
  var availOnly = availableFilter ? availableFilter.checked                 : false;
  var visible   = 0;

  allCards.forEach(function(card) {
    var title     = card.getAttribute('data-title')       || '';
    var author    = card.getAttribute('data-author')      || '';
    var isbn      = card.getAttribute('data-isbn')        || '';
    var cardCat   = card.getAttribute('data-category-id') || '';
    var cardAuth  = card.getAttribute('data-author-id')   || '';
    var cardAvail = parseInt(card.getAttribute('data-available') || '0', 10);

    var textMatch  = q === '' || wordStartMatch(title, q) || wordStartMatch(author, q) || isbn.toLowerCase().indexOf(q) === 0;
    var catMatch   = catId  === '' || cardCat  === catId;
    var authMatch  = authId === '' || cardAuth === authId;
    var availMatch = !availOnly   || cardAvail > 0;

    var show = textMatch && catMatch && authMatch && availMatch;
    card.style.display = show ? '' : 'none';
    if (show) visible++;
  });

  if (bookCount) bookCount.textContent = visible;
  var empty = visible === 0;
  if (noResults) noResults.style.display = empty ? 'block' : 'none';
  if (bookGrid)  bookGrid.style.display  = empty ? 'none'  : 'grid';
}

if (searchInput)     searchInput.addEventListener('input',  applyFilters);
if (categoryFilter)  categoryFilter.addEventListener('change', applyFilters);
if (authorFilter)    authorFilter.addEventListener('change',   applyFilters);
if (availableFilter) availableFilter.addEventListener('change', applyFilters);
</script>
</body>
</html>
