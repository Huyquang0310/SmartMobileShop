<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="${not empty product ? 'Edit Product' : 'Add New Product'}" scope="request"/>
<c:set var="activePage" value="products" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <div class="form-container">
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

          <form method="post" action="${pageContext.request.contextPath}/admin/products?action=${not empty product ? 'update' : 'insert'}"
              class="admin-form" onsubmit="return validateProductForm()">
            <c:if test="${not empty product}">
                <input type="hidden" name="productId" value="${product.productId}">
            </c:if>

            <div class="form-row">
                <div class="form-group">
                    <label for="productName">Product Name <span class="required">*</span></label>
                    <input type="text" id="productName" name="productName"
                           value="${not empty product ? product.productName : productName}"
                           required class="form-control" placeholder="Enter product name">
                    <div class="field-error" id="err-productName"></div>
                </div>
                <div class="form-group">
                    <label for="brandId">Brand <span class="required">*</span></label>
                    <select id="brandId" name="brandId" required class="form-control">
                        <option value="">-- Select Brand --</option>
                        <c:forEach var="brand" items="${brands}">
                            <option value="${brand.brandId}"
                                ${(not empty product and product.brandId == brand.brandId) or selectedBrandId == brand.brandId ? 'selected' : ''}>
                                ${brand.brandName}
                            </option>
                        </c:forEach>
                    </select>
                    <div class="field-error" id="err-brandId"></div>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="categoryId">Category <span class="required">*</span></label>
                    <select id="categoryId" name="categoryId" required class="form-control">
                        <option value="">-- Select Category --</option>
                        <c:forEach var="category" items="${categories}">
                            <option value="${category.categoryId}"
                                ${(not empty product and product.categoryId == category.categoryId) or selectedCategoryId == category.categoryId ? 'selected' : ''}>
                                ${category.categoryName}
                            </option>
                        </c:forEach>
                    </select>
                    <div class="field-error" id="err-categoryId"></div>
                </div>
                <div class="form-group">
                    <label for="price">Price ($) <span class="required">*</span></label>
                    <input type="number" id="price" name="price" step="0.01" min="0.01"
                           value="${not empty product ? product.price : price}"
                           required class="form-control" placeholder="0.00">
                    <div class="field-error" id="err-price"></div>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="quantity">Initial Stock <span class="required">*</span></label>
                    <c:choose>
                        <c:when test="${not empty product}">
                            <input id="quantity" type="number" value="${product.quantity}" class="form-control" disabled>
                            <small class="text-muted">Stock changes are managed in Products → Adjust Stock to prevent overwriting recent orders.</small>
                        </c:when>
                        <c:otherwise>
                            <input type="number" id="quantity" name="quantity" min="0"
                                value="${quantity}" required class="form-control" placeholder="0">
                        </c:otherwise>
                    </c:choose>
                    <div class="field-error" id="err-quantity"></div>
                </div>
                <div class="form-group">
                    <label for="imageUrl">Image URL</label>
                    <input type="text" id="imageUrl" name="imageUrl"
                           value="${not empty product ? product.imageUrl : imageUrl}"
                           class="form-control" placeholder="https://...">
                </div>
            </div>

            <div class="form-group">
                <label for="description">Description</label>
                <textarea id="description" name="description" rows="3" class="form-control" placeholder="Product description...">${not empty product ? product.description : description}</textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="ram">RAM</label>
                    <input type="text" id="ram" name="ram" value="${not empty product ? product.ram : ram}" class="form-control" placeholder="e.g. 8GB">
                </div>
                <div class="form-group">
                    <label for="rom">Storage (ROM)</label>
                    <input type="text" id="rom" name="rom" value="${not empty product ? product.rom : rom}" class="form-control" placeholder="e.g. 256GB">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="screen">Screen</label>
                    <input type="text" id="screen" name="screen" value="${not empty product ? product.screen : screen}" class="form-control" placeholder="e.g. 6.7 inch OLED">
                </div>
                <div class="form-group">
                    <label for="battery">Battery</label>
                    <input type="text" id="battery" name="battery" value="${not empty product ? product.battery : battery}" class="form-control" placeholder="e.g. 5000mAh">
                </div>
            </div>

            <div class="form-group">
                <label for="status">Status</label>
                <select id="status" name="status" class="form-control">
                    <option value="1" ${(not empty product and product.status) or status == '1' ? 'selected' : ''}>Active</option>
                    <option value="0" ${(not empty product and not product.status) or status == '0' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">${not empty product ? 'Update Product' : 'Add Product'}</button>
            </div>
        </form>
    </div>
</div>

<script>
function validateProductForm() {
    let valid = true;
    document.querySelectorAll('.field-error').forEach(e => e.textContent = '');

    const name = document.getElementById('productName').value.trim();
    if (!name) { document.getElementById('err-productName').textContent = 'Product name is required'; valid = false; }
    else if (name.length < 2) { document.getElementById('err-productName').textContent = 'Name must be at least 2 characters'; valid = false; }

    if (!document.getElementById('brandId').value) { document.getElementById('err-brandId').textContent = 'Please select a brand'; valid = false; }
    if (!document.getElementById('categoryId').value) { document.getElementById('err-categoryId').textContent = 'Please select a category'; valid = false; }

    const price = parseFloat(document.getElementById('price').value);
    if (isNaN(price) || price <= 0) { document.getElementById('err-price').textContent = 'Price must be greater than 0'; valid = false; }

    const qty = parseInt(document.getElementById('quantity').value);
    if (isNaN(qty) || qty < 0) { document.getElementById('err-quantity').textContent = 'Quantity must be 0 or more'; valid = false; }

    return valid;
}
</script>

<%@ include file="includes/admin-footer.jsp" %>
