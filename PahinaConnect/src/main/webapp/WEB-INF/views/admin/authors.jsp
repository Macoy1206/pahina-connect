<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Authors - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">✍️ Manage Authors</span>
      <button class="btn btn-primary btn-sm" data-modal="addAuthorModal">➕ Add Author</button>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>
      <div class="search-bar">
        <div class="search-input-wrap">
          <span class="search-icon">🔍</span>
          <input type="text" id="tableSearch" class="form-control" placeholder="Search authors...">
        </div>
      </div>
      <div class="card">
        <div class="card-header"><h3>✍️ Authors (${authors.size()})</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead><tr><th>#</th><th>Name</th><th>Nationality</th><th>Bio</th><th>Actions</th></tr></thead>
              <tbody>
                <c:forEach var="a" items="${authors}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td><strong>${a.fullName}</strong></td>
                    <td>${a.nationality}</td>
                    <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${a.bio}</td>
                    <td>
                      <div class="d-flex gap-1">
                        <button class="btn btn-sm btn-outline"
                                onclick="editAuthor(${a.id},'${a.firstName.replace("'","\\'")}','${a.lastName.replace("'","\\'")}','${a.nationality}','${a.bio.replace("'","\\'")}')">✏️</button>
                        <button class="btn btn-sm btn-danger"
                                onclick="confirmDelete('${pageContext.request.contextPath}/admin/authors?action=delete&id=${a.id}','Delete author: ${a.fullName}?')">🗑️</button>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty authors}">
                  <tr><td colspan="5" class="text-center text-muted" style="padding:20px">No authors yet.</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Add Modal -->
<div class="modal-overlay" id="addAuthorModal">
  <div class="modal">
    <div class="modal-header"><h3>➕ Add Author</h3><button class="modal-close" data-modal-close>✕</button></div>
    <div class="modal-body">
      <form method="post" action="${pageContext.request.contextPath}/admin/authors">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">First Name <span class="required">*</span></label>
            <input type="text" name="firstName" class="form-control" required maxlength="100">
          </div>
          <div class="form-group">
            <label class="form-label">Last Name <span class="required">*</span></label>
            <input type="text" name="lastName" class="form-control" required maxlength="100">
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">Nationality</label>
          <input type="text" name="nationality" class="form-control" placeholder="e.g. Filipino">
        </div>
        <div class="form-group">
          <label class="form-label">Biography</label>
          <textarea name="bio" class="form-control" rows="3" placeholder="Brief biography"></textarea>
        </div>
        <div class="modal-footer" style="padding:0;border:none;margin-top:16px">
          <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
          <button type="submit" class="btn btn-primary">💾 Save</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Edit Modal -->
<div class="modal-overlay" id="editAuthorModal">
  <div class="modal">
    <div class="modal-header"><h3>✏️ Edit Author</h3><button class="modal-close" data-modal-close>✕</button></div>
    <div class="modal-body">
      <form method="post" action="${pageContext.request.contextPath}/admin/authors">
        <input type="hidden" name="authorId" id="editAuthorId">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">First Name <span class="required">*</span></label>
            <input type="text" name="firstName" id="editFirstName" class="form-control" required>
          </div>
          <div class="form-group">
            <label class="form-label">Last Name <span class="required">*</span></label>
            <input type="text" name="lastName" id="editLastName" class="form-control" required>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">Nationality</label>
          <input type="text" name="nationality" id="editNationality" class="form-control">
        </div>
        <div class="form-group">
          <label class="form-label">Biography</label>
          <textarea name="bio" id="editBio" class="form-control" rows="3"></textarea>
        </div>
        <div class="modal-footer" style="padding:0;border:none;margin-top:16px">
          <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
          <button type="submit" class="btn btn-primary">💾 Update</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script>
function editAuthor(id, fn, ln, nat, bio) {
  document.getElementById('editAuthorId').value = id;
  document.getElementById('editFirstName').value = fn;
  document.getElementById('editLastName').value = ln;
  document.getElementById('editNationality').value = nat;
  document.getElementById('editBio').value = bio;
  openModal('editAuthorModal');
}
</script>
</body>
</html>
