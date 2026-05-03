<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Categories - Pahina Connect</title>
  <%@ include file="../includes/head.jsp" %>
</head>
<body>
<div class="wrapper">
  <%@ include file="../includes/admin-sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <span class="topbar-title">🗂️ Manage Categories</span>
      <button class="btn btn-primary btn-sm" data-modal="addCatModal">➕ Add Category</button>
    </div>
    <div class="page-content">
      <%@ include file="../includes/alerts.jsp" %>
      <div class="card">
        <div class="card-header"><h3>📂 Categories (${categories.size()})</h3></div>
        <div class="card-body" style="padding:0">
          <div class="table-wrapper">
            <table>
              <thead><tr><th>#</th><th>Name</th><th>Description</th><th>Actions</th></tr></thead>
              <tbody>
                <c:forEach var="cat" items="${categories}" varStatus="s">
                  <tr>
                    <td>${s.index+1}</td>
                    <td><strong>${cat.name}</strong></td>
                    <td>${cat.description}</td>
                    <td>
                      <div class="d-flex gap-1">
                        <button class="btn btn-sm btn-outline"
                                onclick="editCat(${cat.id},'${cat.name.replace("'","\\'")}','${cat.description.replace("'","\\'")}')">✏️ Edit</button>
                        <button class="btn btn-sm btn-danger"
                                onclick="confirmDelete('${pageContext.request.contextPath}/admin/categories?action=delete&id=${cat.id}','Delete category: ${cat.name}?')">🗑️</button>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty categories}">
                  <tr><td colspan="4" class="text-center text-muted" style="padding:20px">No categories yet.</td></tr>
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
<div class="modal-overlay" id="addCatModal">
  <div class="modal">
    <div class="modal-header"><h3>➕ Add Category</h3><button class="modal-close" data-modal-close>✕</button></div>
    <div class="modal-body">
      <form method="post" action="${pageContext.request.contextPath}/admin/categories">
        <div class="form-group">
          <label class="form-label">Category Name <span class="required">*</span></label>
          <input type="text" name="name" class="form-control" placeholder="e.g. Science Fiction" required maxlength="100">
        </div>
        <div class="form-group">
          <label class="form-label">Description</label>
          <textarea name="description" class="form-control" rows="3" placeholder="Brief description"></textarea>
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
<div class="modal-overlay" id="editCatModal">
  <div class="modal">
    <div class="modal-header"><h3>✏️ Edit Category</h3><button class="modal-close" data-modal-close>✕</button></div>
    <div class="modal-body">
      <form method="post" action="${pageContext.request.contextPath}/admin/categories">
        <input type="hidden" name="categoryId" id="editCatId">
        <div class="form-group">
          <label class="form-label">Category Name <span class="required">*</span></label>
          <input type="text" name="name" id="editCatName" class="form-control" required maxlength="100">
        </div>
        <div class="form-group">
          <label class="form-label">Description</label>
          <textarea name="description" id="editCatDesc" class="form-control" rows="3"></textarea>
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
function editCat(id, name, desc) {
  document.getElementById('editCatId').value = id;
  document.getElementById('editCatName').value = name;
  document.getElementById('editCatDesc').value = desc;
  openModal('editCatModal');
}
</script>
</body>
</html>
