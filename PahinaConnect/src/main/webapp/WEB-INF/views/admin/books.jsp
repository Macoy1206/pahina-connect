<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Manage Books - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">📖 Manage Books</span>
      <button class="btn btn-primary btn-sm" data-modal="addBookModal">➕ Add New Book</button>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>

      <!-- Search -->
      <div class="search-bar">
        <div class="search-input-wrap">
          <span class="search-icon">🔍</span>
          <input type="text" id="tableSearch" class="form-control" placeholder="Search books by title, ISBN, author...">
        </div>
      </div>

      <!-- Books Table -->
      <div class="card">
        <div class="card-header">
          <h3>📚 Book Inventory (${books.size()} books)</h3>
        </div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>#</th><th>Cover</th><th>Title</th><th>Author</th><th>Category</th>
                  <th>ISBN</th><th>Copies</th><th>Available</th><th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="book" items="${books}" varStatus="s">
                  <tr>
                    <td>${s.index + 1}</td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty book.coverImage}">
                          <img src="${pageContext.request.contextPath}/uploads/covers/${book.coverImage}"
                               style="width:40px;height:55px;object-fit:cover;border-radius:4px">
                        </c:when>
                        <c:otherwise><span style="font-size:1.8rem">📖</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <strong>${book.title}</strong>
                      <c:if test="${not empty book.ebookFile}">
                        <span class="badge badge-info" style="margin-left:4px">E-Book</span>
                      </c:if>
                    </td>
                    <td>${book.authorName}</td>
                    <td><span class="badge badge-green">${book.categoryName}</span></td>
                    <td><code>${book.isbn}</code></td>
                    <td>${book.totalCopies}</td>
                    <td>
                      <c:choose>
                        <c:when test="${book.availableCopies gt 0}">
                          <span class="badge badge-success">${book.availableCopies}</span>
                        </c:when>
                        <c:otherwise><span class="badge badge-danger">0</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="d-flex gap-1">
                        <a href="${pageContext.request.contextPath}/admin/books?action=qr&id=${book.id}"
                           class="btn btn-sm btn-gold" title="QR Code">📱</a>
                        <button class="btn btn-sm btn-outline" title="Edit"
                                data-book-id="${book.id}"
                                data-book-isbn="${book.isbn}"
                                data-book-title="${book.title}"
                                data-book-author="${book.authorId}"
                                data-book-category="${book.categoryId}"
                                data-book-publisher="${book.publisher}"
                                data-book-year="${book.publicationYear}"
                                data-book-edition="${book.edition}"
                                data-book-copies="${book.totalCopies}"
                                data-book-desc="${book.description}"
                                data-book-location="${book.location}"
                                data-book-language="${book.language}"
                                data-book-pages="${book.pages}"
                                onclick="editBookFromData(this)">✏️</button>
                        <button class="btn btn-sm btn-danger" title="Delete"
                                onclick="confirmDelete('${pageContext.request.contextPath}/admin/books?action=delete&id=${book.id}','Delete this book?')">🗑️</button>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty books}">
                  <tr><td colspan="9" class="text-center text-muted" style="padding:30px">No books found. Add your first book!</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Add Book Modal -->
<div class="modal-overlay" id="addBookModal">
  <div class="modal" style="max-width:700px">
    <div class="modal-header">
      <h3>➕ Add New Book</h3>
      <button class="modal-close" data-modal-close>✕</button>
    </div>
    <div class="modal-body">
      <form method="post" action="${pageContext.request.contextPath}/admin/books" enctype="multipart/form-data">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">ISBN <span class="required">*</span></label>
            <input type="text" name="isbn" class="form-control" placeholder="978-XXX-XXX-XXXX-X" required>
          </div>
          <div class="form-group">
            <label class="form-label">Title <span class="required">*</span></label>
            <input type="text" name="title" class="form-control" placeholder="Book title" required>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Author <span class="required">*</span></label>
            <select name="authorId" class="form-control" required>
              <option value="">-- Select Author --</option>
              <c:forEach var="a" items="${authors}">
                <option value="${a.id}">${a.fullName}</option>
              </c:forEach>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Category <span class="required">*</span></label>
            <select name="categoryId" class="form-control" required>
              <option value="">-- Select Category --</option>
              <c:forEach var="c" items="${categories}">
                <option value="${c.id}">${c.name}</option>
              </c:forEach>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Publisher</label>
            <input type="text" name="publisher" class="form-control" placeholder="Publisher name">
          </div>
          <div class="form-group">
            <label class="form-label">Publication Year</label>
            <input type="number" name="publicationYear" class="form-control" placeholder="2024" min="1000" max="2099">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Edition</label>
            <input type="text" name="edition" class="form-control" placeholder="1st Edition">
          </div>
          <div class="form-group">
            <label class="form-label">Total Copies <span class="required">*</span></label>
            <input type="number" name="totalCopies" class="form-control" value="1" min="1" required>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Location / Shelf</label>
            <input type="text" name="location" class="form-control" placeholder="Shelf A-1">
          </div>
          <div class="form-group">
            <label class="form-label">Language</label>
            <select name="language" class="form-control">
              <option value="English">English</option>
              <option value="Filipino">Filipino</option>
              <option value="Spanish">Spanish</option>
              <option value="Other">Other</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Pages</label>
            <input type="number" name="pages" class="form-control" placeholder="0" min="0">
          </div>
          <div class="form-group">
            <label class="form-label">Cover Image</label>
            <input type="file" name="coverImage" class="form-control" accept="image/*">
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">E-Book File (PDF)</label>
          <input type="file" name="ebookFile" class="form-control" accept=".pdf">
        </div>
        <div class="form-group">
          <label class="form-label">Description</label>
          <textarea name="description" class="form-control" rows="3" placeholder="Brief description of the book"></textarea>
        </div>
        <div class="modal-footer" style="padding:0;border:none;margin-top:16px">
          <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
          <button type="submit" class="btn btn-primary">💾 Save Book</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Edit Book Modal -->
<div class="modal-overlay" id="editBookModal">
  <div class="modal" style="max-width:700px">
    <div class="modal-header">
      <h3>✏️ Edit Book</h3>
      <button class="modal-close" data-modal-close>✕</button>
    </div>
    <div class="modal-body">
      <form method="post" action="${pageContext.request.contextPath}/admin/books" enctype="multipart/form-data">
        <input type="hidden" name="bookId" id="editBookId">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">ISBN <span class="required">*</span></label>
            <input type="text" name="isbn" id="editIsbn" class="form-control" required>
          </div>
          <div class="form-group">
            <label class="form-label">Title <span class="required">*</span></label>
            <input type="text" name="title" id="editTitle" class="form-control" required>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Author</label>
            <select name="authorId" id="editAuthorId" class="form-control">
              <c:forEach var="a" items="${authors}">
                <option value="${a.id}">${a.fullName}</option>
              </c:forEach>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Category</label>
            <select name="categoryId" id="editCategoryId" class="form-control">
              <c:forEach var="c" items="${categories}">
                <option value="${c.id}">${c.name}</option>
              </c:forEach>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Publisher</label>
            <input type="text" name="publisher" id="editPublisher" class="form-control">
          </div>
          <div class="form-group">
            <label class="form-label">Publication Year</label>
            <input type="number" name="publicationYear" id="editYear" class="form-control">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Edition</label>
            <input type="text" name="edition" id="editEdition" class="form-control">
          </div>
          <div class="form-group">
            <label class="form-label">Total Copies</label>
            <input type="number" name="totalCopies" id="editCopies" class="form-control" min="1">
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Location</label>
            <input type="text" name="location" id="editLocation" class="form-control">
          </div>
          <div class="form-group">
            <label class="form-label">Pages</label>
            <input type="number" name="pages" id="editPages" class="form-control">
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">Description</label>
          <textarea name="description" id="editDescription" class="form-control" rows="3"></textarea>
        </div>
        <div class="modal-footer" style="padding:0;border:none;margin-top:16px">
          <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
          <button type="submit" class="btn btn-primary">💾 Update Book</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
function editBookFromData(btn) {
  document.getElementById('editBookId').value       = btn.getAttribute('data-book-id');
  document.getElementById('editIsbn').value         = btn.getAttribute('data-book-isbn');
  document.getElementById('editTitle').value        = btn.getAttribute('data-book-title');
  document.getElementById('editAuthorId').value     = btn.getAttribute('data-book-author');
  document.getElementById('editCategoryId').value   = btn.getAttribute('data-book-category');
  document.getElementById('editPublisher').value    = btn.getAttribute('data-book-publisher');
  document.getElementById('editYear').value         = btn.getAttribute('data-book-year');
  document.getElementById('editEdition').value      = btn.getAttribute('data-book-edition');
  document.getElementById('editCopies').value       = btn.getAttribute('data-book-copies');
  document.getElementById('editDescription').value  = btn.getAttribute('data-book-desc');
  document.getElementById('editLocation').value     = btn.getAttribute('data-book-location');
  document.getElementById('editPages').value        = btn.getAttribute('data-book-pages');
  openModal('editBookModal');
}

// Table search
var searchInput = document.getElementById('tableSearch');
if (searchInput) {
  searchInput.addEventListener('input', function() {
    var q = this.value.toLowerCase();
    document.querySelectorAll('tbody tr').forEach(function(row) {
      row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  });
}
</script>
</body>
</html>
