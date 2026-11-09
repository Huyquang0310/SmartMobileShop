<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="${not empty category ? 'Edit Category' : 'Add New Category'}" scope="request"/>
<c:set var="activePage" value="categories" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <div class="form-container">
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

          <form method="post" action="${pageContext.request.contextPath}/admin/categories?action=${not empty category ? 'update' : 'insert'}"
              onsubmit="return validateCategoryForm()">
            <c:if test="${not empty category}">
                <input type="hidden" name="categoryId" value="${category.categoryId}">
            </c:if>

            <div class="form-group">
                <label for="categoryName">Category Name <span class="required">*</span></label>
                <input type="text" id="categoryName" name="categoryName"
                       value="${not empty category ? category.categoryName : categoryName}"
                       required class="form-control" placeholder="Enter category name">
                <div class="field-error" id="err-categoryName"></div>
            </div>

            <div class="form-group">
                <label for="status">Status</label>
                <select id="status" name="status" class="form-control">
                    <option value="1" ${(not empty category and category.status) or status == '1' ? 'selected' : ''}>Active</option>
                    <option value="0" ${(not empty category and not category.status) or status == '0' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>

            <div class="alert alert-warning mt-3">When this category is Inactive, all assigned products are hidden from the storefront, product search, details and checkout. Existing orders and inventory remain unchanged.</div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">${not empty category ? 'Update Category' : 'Add Category'}</button>
            </div>
        </form>
    </div>
</div>

<script>
function validateCategoryForm() {
    document.getElementById('err-categoryName').textContent = '';
    var name = document.getElementById('categoryName').value.trim();
    if (!name) { document.getElementById('err-categoryName').textContent = 'Category name is required'; return false; }
    if (name.length < 2) { document.getElementById('err-categoryName').textContent = 'Name must be at least 2 characters'; return false; }
    if (document.getElementById('status').value === '0') {
        return confirm('Setting this category to Inactive will hide its products from customers. Continue?');
    }
    return true;
}
</script>

<%@ include file="includes/admin-footer.jsp" %>
