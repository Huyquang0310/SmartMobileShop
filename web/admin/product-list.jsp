<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Product Management" scope="request"/>
<c:set var="activePage" value="products" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <div class="content-header">
        <h3>Products <small class="text-muted">(${totalItems} matches)</small></h3>
        <a href="${pageContext.request.contextPath}/admin/products?action=form" class="btn btn-primary">+ Add Product</a>
    </div>
    <form method="get" action="${pageContext.request.contextPath}/admin/products" class="row g-2 align-items-end mb-4">
        <div class="col-md-3">
            <label class="form-label" for="keyword">Product name, brand, category</label>
            <input type="text" id="keyword" name="keyword" value="<c:out value='${keyword}'/>" placeholder="Search..." class="form-control">
        </div>
        <div class="col-md-2">
            <label class="form-label" for="brandId">Brand</label>
            <select name="brandId" id="brandId" class="form-select">
                <option value="">All brands</option>
                <c:forEach var="brand" items="${brands}">
                    <option value="${brand.brandId}" ${selectedBrandId == brand.brandId ? 'selected' : ''}>${brand.brandName}${brand.status ? '' : ' (Inactive)'}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label" for="categoryId">Category</label>
            <select name="categoryId" id="categoryId" class="form-select">
                <option value="">All categories</option>
                <c:forEach var="category" items="${categories}">
                    <option value="${category.categoryId}" ${selectedCategoryId == category.categoryId ? 'selected' : ''}>${category.categoryName}${category.status ? '' : ' (Inactive)'}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label" for="visibility">Visibility</label>
            <select name="visibility" id="visibility" class="form-select">
                <option value="">All</option>
                <option value="visible" ${visibility == 'visible' ? 'selected' : ''}>Visible in shop</option>
                <option value="hidden" ${visibility == 'hidden' ? 'selected' : ''}>Hidden in shop</option>
                <option value="inactive" ${visibility == 'inactive' ? 'selected' : ''}>Product inactive</option>
                <option value="brand_hidden" ${visibility == 'brand_hidden' ? 'selected' : ''}>Brand inactive</option>
                <option value="category_hidden" ${visibility == 'category_hidden' ? 'selected' : ''}>Category inactive</option>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label" for="stock">Stock</label>
            <select name="stock" id="stock" class="form-select">
                <option value="">All stock levels</option>
                <option value="out" ${stockFilter == 'out' ? 'selected' : ''}>Out of stock (0)</option>
                <option value="low" ${stockFilter == 'low' ? 'selected' : ''}>Low stock (1–5)</option>
                <option value="available" ${stockFilter == 'available' ? 'selected' : ''}>More than 5</option>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label" for="sortBy">Sort</label>
            <select name="sortBy" id="sortBy" class="form-select">
                <option value="">Newest</option>
                <option value="stock_asc" ${sortBy == 'stock_asc' ? 'selected' : ''}>Lowest stock</option>
                <option value="stock_desc" ${sortBy == 'stock_desc' ? 'selected' : ''}>Highest stock</option>
                <option value="price_asc" ${sortBy == 'price_asc' ? 'selected' : ''}>Lowest price</option>
                <option value="price_desc" ${sortBy == 'price_desc' ? 'selected' : ''}>Highest price</option>
                <option value="name_asc" ${sortBy == 'name_asc' ? 'selected' : ''}>Name A–Z</option>
            </select>
        </div>
        <div class="col-auto"><button type="submit" class="btn btn-primary">Apply Filters</button></div>
        <div class="col-auto"><a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/products">Reset</a></div>
    </form>
    <c:if test="${not empty param.message}">
        <div class="alert alert-success">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-error">${param.error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty products}">
            <div class="table-responsive">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Image</th>
                        <th>Name</th>
                        <th>Brand</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="product" items="${products}">
                        <tr>
                            <td>${product.productId}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty product.imageUrl and (product.imageUrl.startsWith('http://') or product.imageUrl.startsWith('https://'))}">
                                        <img src="${product.imageUrl}" alt="${product.productName}" class="table-image">
                                    </c:when>
                                    <c:when test="${not empty product.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/images/${product.imageUrl}" alt="${product.productName}" class="table-image">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/images/no-image.jpg" alt="No Image" class="table-image">
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${product.productName}</td>
                            <td>${product.brandName}</td>
                            <td>${product.categoryName}</td>
                            <td><fmt:formatNumber value="${product.price}" type="currency" currencySymbol="$"/></td>
                            <td>
                                <strong class="${product.quantity == 0 ? 'text-danger' : product.quantity <= 5 ? 'text-warning' : ''}">${product.quantity}</strong>
                                <c:if test="${product.quantity == 0}"><small class="d-block text-danger">Out of stock</small></c:if>
                                <c:if test="${product.quantity > 0 and product.quantity <= 5}"><small class="d-block text-warning">Low stock</small></c:if>
                            </td>
                            <td>
                                <span class="status ${product.visible ? 'active' : 'inactive'}">${product.visible ? 'Visible' : 'Hidden'}</span>
                                <c:if test="${not product.status}"><small class="d-block">Product inactive</small></c:if>
                                <c:if test="${not product.brandActive}"><small class="d-block">Brand inactive</small></c:if>
                                <c:if test="${not product.categoryActive}"><small class="d-block">Category inactive</small></c:if>
                            </td>
                            <td class="actions">
                                <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${product.productId}" class="btn btn-small btn-primary">Edit</a>
                                <form method="post" action="${pageContext.request.contextPath}/admin/products?action=adjust-stock" class="d-inline-flex gap-1 align-items-center mt-1" onsubmit="return confirm('Apply this stock adjustment?')">
                                    <input type="hidden" name="productId" value="${product.productId}">
                                    <select name="direction" class="form-select form-select-sm" aria-label="Stock adjustment direction" style="width:85px">
                                        <option value="add">+ Add</option><option value="remove">− Remove</option>
                                    </select>
                                    <input type="number" name="amount" min="1" max="1000000" value="1" required aria-label="Stock units" class="form-control form-control-sm" style="width:65px">
                                    <button type="submit" class="btn btn-small btn-outline-secondary">Adjust</button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/admin/products?action=delete" class="d-inline-block" onsubmit="return confirm('Delete this product? Products with order history cannot be deleted; use Inactive instead.')">
                                    <input type="hidden" name="id" value="${product.productId}">
                                    <button type="submit" class="btn btn-small btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table></div>
            <%@ include file="includes/pagination.jsp" %>
        </c:when>
        <c:otherwise>
            <div class="no-data">
                <p>No products found.</p>
                <a href="${pageContext.request.contextPath}/admin/products?action=form" class="btn btn-primary">Add First Product</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="includes/admin-footer.jsp" %>
