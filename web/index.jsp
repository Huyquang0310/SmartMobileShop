<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="includes/header.jsp" %>

<div class="shop-home">
    <div class="shop-home-heading">
        <div>
            <span class="shop-eyebrow">SMART MOBILE SHOP</span>
            <h1 class="shop-page-title">All Products</h1>
        </div>
        <span class="shop-results-count">${totalProducts} products</span>
    </div>

    <div class="shop-layout">
        <aside class="shop-filters" aria-label="Product filters">
            <details class="shop-filter-panel" id="shop-filter-panel" open>
                <summary class="shop-filter-heading">
                    <div class="shop-filter-title">
                        <svg aria-hidden="true" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7h16M7 12h10M10 17h4"/></svg>
                        <h2>Filters</h2>
                    </div>
                    <span class="shop-filter-toggle-hint"><c:if test="${hasActiveFilters}">Active</c:if><span class="shop-filter-chevron" aria-hidden="true">&#8964;</span></span>
                </summary>
                <form method="get" action="${pageContext.request.contextPath}/home#all-products" class="shop-filter-form">
                    <div class="shop-field">
                        <label for="shop-search">Search products</label>
                        <div class="shop-search-wrap">
                            <svg aria-hidden="true" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="10.8" cy="10.8" r="6.5"/><path d="m16 16 4 4"/></svg>
                            <input id="shop-search" type="search" name="keyword" value="<c:out value='${keyword}'/>" placeholder="Search by name..." autocomplete="off" class="form-control">
                        </div>
                    </div>
                    <div class="shop-field">
                        <label for="shop-brand">Brand</label>
                        <select id="shop-brand" name="brandId" class="form-select">
                            <option value="">All brands</option>
                            <c:forEach var="brand" items="${brands}">
                                <option value="${brand.brandId}" ${selectedBrandId == brand.brandId ? 'selected' : ''}><c:out value="${brand.brandName}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="shop-field">
                        <label for="shop-category">Category</label>
                        <select id="shop-category" name="categoryId" class="form-select">
                            <option value="">All categories</option>
                            <c:forEach var="category" items="${categories}">
                                <option value="${category.categoryId}" ${selectedCategoryId == category.categoryId ? 'selected' : ''}><c:out value="${category.categoryName}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="shop-field">
                        <label>Price range</label>
                        <div class="shop-price-fields">
                            <input type="number" name="minPrice" value="<c:out value='${minPrice}'/>" placeholder="Min ($)" aria-label="Minimum price" min="0" step="0.01" class="form-control">
                            <input type="number" name="maxPrice" value="<c:out value='${maxPrice}'/>" placeholder="Max ($)" aria-label="Maximum price" min="0" step="0.01" class="form-control">
                        </div>
                    </div>
                    <div class="shop-field">
                        <label for="shop-sort">Sort by</label>
                        <select id="shop-sort" name="sortBy" class="form-select">
                            <option value="">Recommended</option>
                            <option value="price_asc" ${sortBy == 'price_asc' ? 'selected' : ''}>Price: Low to High</option>
                            <option value="price_desc" ${sortBy == 'price_desc' ? 'selected' : ''}>Price: High to Low</option>
                            <option value="name_asc" ${sortBy == 'name_asc' ? 'selected' : ''}>Name: A–Z</option>
                            <option value="name_desc" ${sortBy == 'name_desc' ? 'selected' : ''}>Name: Z–A</option>
                        </select>
                    </div>
                    <div class="shop-filter-actions">
                        <button type="submit" class="shop-apply-button">Show Results <span aria-hidden="true">&#8594;</span></button>
                        <a class="shop-filter-reset" href="${pageContext.request.contextPath}/home#all-products">Clear filters</a>
                    </div>
                </form>
            </details>
        </aside>

        <section class="shop-products" id="all-products" aria-label="All products">
            <div class="shop-results-heading">
                <div>
                    <h2>Browse phones</h2>
                    <p>${totalProducts} results<c:if test="${hasActiveFilters}"> · Filtered</c:if></p>
                </div>
                <c:if test="${hasActiveFilters}">
                    <a href="${pageContext.request.contextPath}/home#all-products" class="shop-clear-filters">Clear filters &#215;</a>
                </c:if>
            </div>
            <div class="shop-product-grid">
                <c:choose>
                    <c:when test="${not empty products}">
                        <c:forEach var="product" items="${products}">
                            <article class="shop-product-card">
                                <a class="shop-product-media" href="${pageContext.request.contextPath}/product-details?id=${product.productId}" aria-label="View <c:out value='${product.productName}'/>">
                                    <c:choose>
                                        <c:when test="${not empty product.imageUrl and (product.imageUrl.startsWith('http://') or product.imageUrl.startsWith('https://'))}">
                                            <img loading="lazy" decoding="async" src="<c:out value='${product.imageUrl}'/>" alt="<c:out value='${product.productName}'/>">
                                        </c:when>
                                        <c:when test="${not empty product.imageUrl}">
                                            <img loading="lazy" decoding="async" src="${pageContext.request.contextPath}/images/<c:out value='${product.imageUrl}'/>" alt="<c:out value='${product.productName}'/>">
                                        </c:when>
                                        <c:otherwise>
                                            <img loading="lazy" decoding="async" src="${pageContext.request.contextPath}/images/no-image.jpg" alt="Product image unavailable">
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="shop-card-brand"><c:out value="${product.brandName}"/></span>
                                </a>
                                <div class="shop-card-content">
                                    <h3><a href="${pageContext.request.contextPath}/product-details?id=${product.productId}"><c:out value="${product.productName}"/></a></h3>
                                    <div class="shop-card-price"><fmt:formatNumber value="${product.price}" type="currency" currencySymbol="$"/></div>
                                    <div class="shop-card-footer">
                                        <c:choose>
                                            <c:when test="${product.quantity > 0}"><span class="shop-stock shop-stock-available"><span aria-hidden="true" class="shop-stock-dot"></span> In stock</span></c:when>
                                            <c:otherwise><span class="shop-stock shop-stock-empty"><span aria-hidden="true" class="shop-stock-dot"></span> Out of stock</span></c:otherwise>
                                        </c:choose>
                                        <a class="shop-card-action" href="${pageContext.request.contextPath}/product-details?id=${product.productId}" aria-label="View details for <c:out value='${product.productName}'/>">
                                            <span>View details</span><span aria-hidden="true">&#8594;</span>
                                        </a>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="shop-empty-results">
                            <div class="shop-empty-icon" aria-hidden="true">&#8981;</div>
                            <h3>No products found</h3>
                            <p>Try changing your search or filters.</p>
                            <a href="${pageContext.request.contextPath}/home#all-products" class="shop-apply-button">View all products</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:if test="${totalPages > 1}">
                <c:url var="qBase" value="/home">
                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    <c:if test="${not empty selectedBrandId}"><c:param name="brandId" value="${selectedBrandId}"/></c:if>
                    <c:if test="${not empty selectedCategoryId}"><c:param name="categoryId" value="${selectedCategoryId}"/></c:if>
                    <c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
                    <c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
                    <c:if test="${not empty sortBy}"><c:param name="sortBy" value="${sortBy}"/></c:if>
                </c:url>
                <c:set var="pageSep" value="${fn:contains(qBase, '?') ? '&amp;' : '?'}"/>
                <nav class="shop-pagination" aria-label="Product pages">
                    <ul class="pagination justify-content-center flex-wrap">
                        <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}"><a class="page-link" href="${qBase}${pageSep}page=${currentPage - 1}#all-products" aria-label="Previous page">&#8592; Prev</a></li>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:choose>
                                <c:when test="${p == 1 or p == totalPages or (p >= currentPage - 2 and p <= currentPage + 2)}">
                                    <li class="page-item ${p == currentPage ? 'active' : ''}"><a class="page-link" href="${qBase}${pageSep}page=${p}#all-products">${p}</a></li>
                                </c:when>
                                <c:when test="${(p == 2 and currentPage > 4) or (p == totalPages - 1 and currentPage < totalPages - 3)}"><li class="page-item disabled"><span class="page-link">&#8230;</span></li></c:when>
                            </c:choose>
                        </c:forEach>
                        <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}"><a class="page-link" href="${qBase}${pageSep}page=${currentPage + 1}#all-products" aria-label="Next page">Next &#8594;</a></li>
                    </ul>
                    <p>Page ${currentPage} of ${totalPages}</p>
                </nav>
            </c:if>
        </section>
    </div>

    <c:if test="${showRecommendations}">
        <section class="shop-collections" aria-label="Product collections">
            <div class="shop-collections-header"><span class="shop-eyebrow">MORE TO EXPLORE</span><h2>Popular collections</h2></div>
            <c:if test="${not empty featuredProducts}">
                <c:set var="sectionTitle" value="Featured Phones"/>
                <c:set var="sectionProducts" value="${featuredProducts}"/>
                <%@ include file="includes/product-strip.jsp" %>
            </c:if>
            <c:if test="${not empty newArrivals}">
                <c:set var="sectionTitle" value="New Arrivals"/>
                <c:set var="sectionProducts" value="${newArrivals}"/>
                <%@ include file="includes/product-strip.jsp" %>
            </c:if>
            <c:if test="${not empty bestSellers}">
                <c:set var="sectionTitle" value="Best Sellers"/>
                <c:set var="sectionProducts" value="${bestSellers}"/>
                <%@ include file="includes/product-strip.jsp" %>
            </c:if>
        </section>
    </c:if>
</div>

<script>
    (() => {
        const panel = document.getElementById('shop-filter-panel');
        const narrow = window.matchMedia('(max-width: 850px)');
        const adapt = () => { panel.open = !narrow.matches; };
        adapt();
        narrow.addEventListener('change', adapt);
    })();
</script>

<%@ include file="includes/footer.jsp" %>
