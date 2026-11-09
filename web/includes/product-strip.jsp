<div class="shop-collection-group">
    <div class="shop-collection-heading"><h3><c:out value="${sectionTitle}"/></h3></div>
    <div class="shop-collection-grid">
        <c:forEach var="featured" items="${sectionProducts}">
            <a class="shop-collection-item" href="${pageContext.request.contextPath}/product-details?id=${featured.productId}">
                <div class="shop-collection-media">
                    <c:choose>
                        <c:when test="${not empty featured.imageUrl and (featured.imageUrl.startsWith('http://') or featured.imageUrl.startsWith('https://'))}">
                            <img loading="lazy" decoding="async" src="<c:out value='${featured.imageUrl}'/>" alt="<c:out value='${featured.productName}'/>">
                        </c:when>
                        <c:when test="${not empty featured.imageUrl}">
                            <img loading="lazy" decoding="async" src="${pageContext.request.contextPath}/images/<c:out value='${featured.imageUrl}'/>" alt="<c:out value='${featured.productName}'/>">
                        </c:when>
                        <c:otherwise><img loading="lazy" decoding="async" src="${pageContext.request.contextPath}/images/no-image.jpg" alt="Product image unavailable"></c:otherwise>
                    </c:choose>
                </div>
                <div class="shop-collection-content">
                    <span class="shop-collection-brand"><c:out value="${featured.brandName}"/></span>
                    <span class="shop-collection-name"><c:out value="${featured.productName}"/></span>
                    <span class="shop-collection-price"><fmt:formatNumber value="${featured.price}" type="currency" currencySymbol="$"/></span>
                </div>
            </a>
        </c:forEach>
    </div>
</div>
