<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="${not empty brand ? 'Edit Brand' : 'Add New Brand'}" scope="request"/>
<c:set var="activePage" value="brands" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <div class="form-container">
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

          <form method="post" action="${pageContext.request.contextPath}/admin/brands?action=${not empty brand ? 'update' : 'insert'}"
              onsubmit="return validateBrandForm()">
            <c:if test="${not empty brand}">
                <input type="hidden" name="brandId" value="${brand.brandId}">
            </c:if>

            <div class="form-group">
                <label for="brandName">Brand Name <span class="required">*</span></label>
                <input type="text" id="brandName" name="brandName"
                       value="${not empty brand ? brand.brandName : brandName}"
                       required class="form-control" placeholder="Enter brand name">
                <div class="field-error" id="err-brandName"></div>
            </div>

            <div class="form-group">
                <label for="status">Status</label>
                <select id="status" name="status" class="form-control">
                    <option value="1" ${(not empty brand and brand.status) or status == '1' ? 'selected' : ''}>Active</option>
                    <option value="0" ${(not empty brand and not brand.status) or status == '0' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>

            <div class="alert alert-warning mt-3">When this brand is Inactive, all assigned products are hidden from the storefront, product search, details and checkout. Existing orders and inventory remain unchanged.</div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/admin/brands" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">${not empty brand ? 'Update Brand' : 'Add Brand'}</button>
            </div>
        </form>
    </div>
</div>

<script>
function validateBrandForm() {
    document.getElementById('err-brandName').textContent = '';
    var name = document.getElementById('brandName').value.trim();
    if (!name) { document.getElementById('err-brandName').textContent = 'Brand name is required'; return false; }
    if (name.length < 2) { document.getElementById('err-brandName').textContent = 'Name must be at least 2 characters'; return false; }
    if (document.getElementById('status').value === '0') {
        return confirm('Setting this brand to Inactive will hide its products from customers. Continue?');
    }
    return true;
}
</script>

<%@ include file="includes/admin-footer.jsp" %>
