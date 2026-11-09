<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="includes/header.jsp" %>

<div class="container mt-2">
    <div class="card shadow-sm p-4 mb-4">
        <div class="row g-4">
            <div class="col-md-5">
                <div class="product-img-wrap rounded border" style="height: 380px;">
                    <c:choose>
                        <c:when test="${not empty product.imageUrl and (product.imageUrl.startsWith('http://') or product.imageUrl.startsWith('https://'))}">
                            <img src="${product.imageUrl}" alt="${product.productName}">
                        </c:when>
                        <c:when test="${not empty product.imageUrl}">
                            <img src="${pageContext.request.contextPath}/images/${product.imageUrl}" alt="${product.productName}">
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/images/no-image.jpg" alt="No Image">
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="col-md-7">
                <h2 class="mb-3">${product.productName}</h2>

                <div class="mb-3 small">
                    <p class="mb-1"><strong>Brand:</strong> ${product.brandName}</p>
                    <p class="mb-1"><strong>Category:</strong> ${product.categoryName}</p>
                    <p class="mb-1"><strong>Price:</strong> <span class="product-price"><fmt:formatNumber value="${product.price}" type="currency" currencySymbol="$"/></span></p>
                    <p class="mb-0">
                        <strong>Stock:</strong>
                        <c:choose>
                            <c:when test="${product.quantity > 0}">
                                <span class="text-success fw-medium">${product.quantity} units available</span>
                            </c:when>
                            <c:otherwise>
                                <span class="text-danger fw-medium">Out of Stock</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <div class="mb-3">
                    <h5>Specifications</h5>
                    <table class="table table-sm mb-0">
                        <tbody>
                            <c:if test="${not empty product.ram}">
                                <tr><th style="width: 120px;">RAM</th><td>${product.ram}</td></tr>
                            </c:if>
                            <c:if test="${not empty product.rom}">
                                <tr><th>Storage</th><td>${product.rom}</td></tr>
                            </c:if>
                            <c:if test="${not empty product.screen}">
                                <tr><th>Screen</th><td>${product.screen}</td></tr>
                            </c:if>
                            <c:if test="${not empty product.battery}">
                                <tr><th>Battery</th><td>${product.battery}</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <c:if test="${not empty product.description}">
                    <div class="mb-3">
                        <h5>Description</h5>
                        <p class="text-muted mb-0">${product.description}</p>
                    </div>
                </c:if>

                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger">${param.error}</div>
                </c:if>
                <c:if test="${not empty param.message}">
                    <div class="alert alert-success">${param.message}</div>
                </c:if>

                <c:choose>
                    <c:when test="${product.quantity > 0}">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <label for="quantity" class="form-label mb-0">Quantity:</label>
                            <input type="number" id="quantity" name="quantityInput" value="1"
                                   min="1" max="${product.quantity}" class="form-control form-control-sm"
                                   style="width: 90px;" onchange="updateQuantity(this.value)">
                        </div>

                        <div class="d-flex gap-2 flex-wrap">
                            <form method="post" action="${pageContext.request.contextPath}/cart?action=add" class="m-0">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <input type="hidden" name="quantity" id="addCartQty" value="1">
                                <button type="submit" class="btn btn-outline-secondary">Add to Cart</button>
                            </form>

                            <form method="post" action="${pageContext.request.contextPath}/cart?action=buy-now" class="m-0">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <input type="hidden" name="quantity" id="buyNowQty" value="1">
                                <button type="submit" class="btn btn-primary">Buy Now</button>
                            </form>
                        </div>

                        <script>
                            function updateQuantity(val) {
                                document.getElementById('addCartQty').value = val;
                                document.getElementById('buyNowQty').value = val;
                            }
                        </script>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-warning mb-0">This product is currently out of stock.</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary">&larr; Back to Products</a>
    </div>

    <section id="questions" class="card shadow-sm p-4 mb-4" style="scroll-margin-top:95px">
        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
            <h4 class="mb-0">Questions &amp; Answers</h4>
            <c:if test="${not empty sessionScope.LOGIN_USER}"><a class="btn btn-outline-primary btn-sm" href="${pageContext.request.contextPath}/my-qa">My Q&amp;A History</a></c:if>
        </div>
        <p class="text-muted">Ask about this product or help other shoppers. Your pending submissions remain visible to you while awaiting moderation.</p>
        <c:choose>
            <c:when test="${empty questions}"><p class="text-muted">No questions yet. Be the first to ask.</p></c:when>
            <c:otherwise>
                <c:forEach var="q" items="${questions}">
                    <article id="question-${q.questionId}" class="border rounded p-3 mb-3" style="scroll-margin-top:95px">
                        <div class="d-flex justify-content-between gap-2 flex-wrap mb-2">
                            <div class="small text-muted">By <c:out value="${q.authorName}"/><c:if test="${not empty q.createdAt}"> &middot; <fmt:formatDate value="${q.createdAt}" pattern="dd MMM yyyy, HH:mm"/></c:if></div>
                            <c:if test="${q.status != 'Approved' || sessionScope.LOGIN_USER.admin}"><span class="badge ${q.status == 'Approved' ? 'text-bg-success' : q.status == 'Pending' ? 'text-bg-warning' : 'text-bg-secondary'}"><c:out value="${q.status}"/></span></c:if>
                        </div>
                        <div class="fw-semibold mb-3" style="white-space:pre-wrap;overflow-wrap:anywhere">Q: <c:out value="${q.content}"/></div>
                        <c:forEach var="a" items="${q.answers}">
                            <div class="ms-md-3 mt-2 border-start border-primary border-3 ps-3 py-2 bg-light rounded">
                                <div style="white-space:pre-wrap;overflow-wrap:anywhere"><strong>A: </strong><c:out value="${a.content}"/></div>
                                <div class="small text-muted mt-1">By <c:out value="${a.authorName}"/><c:if test="${not empty a.createdAt}"> &middot; <fmt:formatDate value="${a.createdAt}" pattern="dd MMM yyyy, HH:mm"/></c:if>
                                    <c:if test="${a.status != 'Approved' || sessionScope.LOGIN_USER.admin}"><span class="badge ms-2 ${a.status == 'Approved' ? 'text-bg-success' : a.status == 'Pending' ? 'text-bg-warning' : 'text-bg-secondary'}"><c:out value="${a.status}"/></span></c:if>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${q.status == 'Approved' && not empty sessionScope.LOGIN_USER}">
                            <form method="post" action="${pageContext.request.contextPath}/qa" class="mt-3">
                                <input type="hidden" name="action" value="reply">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <input type="hidden" name="questionId" value="${q.questionId}">
                                <label class="form-label" for="reply-${q.questionId}">Add a reply</label>
                                <textarea id="reply-${q.questionId}" name="content" class="form-control mb-2" minlength="5" maxlength="2000" rows="2" required></textarea>
                                <button type="submit" class="btn btn-outline-primary btn-sm">Submit Reply</button>
                            </form>
                        </c:if>
                    </article>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        <c:choose>
            <c:when test="${not empty sessionScope.LOGIN_USER}">
                <form method="post" action="${pageContext.request.contextPath}/qa" class="mt-3">
                    <input type="hidden" name="action" value="ask">
                    <input type="hidden" name="productId" value="${product.productId}">
                    <label class="form-label fw-semibold" for="qa-question">Ask a question</label>
                    <textarea id="qa-question" name="content" class="form-control mb-2" rows="3" minlength="5" maxlength="2000" required placeholder="What would you like to know about this phone?"></textarea>
                    <button type="submit" class="btn btn-primary">Submit Question</button>
                </form>
            </c:when>
            <c:otherwise>
                <c:url var="qaLoginUrl" value="/auth">
                    <c:param name="action" value="login"/>
                    <c:param name="redirect" value="${pageContext.request.contextPath}/product-details?id=${product.productId}#questions"/>
                </c:url>
                <a href="${qaLoginUrl}" class="btn btn-outline-primary">Sign in to ask or answer</a>
            </c:otherwise>
        </c:choose>
    </section>

    <c:if test="${not empty relatedProducts}">
        <h4 class="mb-3">Related Products</h4>
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-xl-4 g-3">
            <c:forEach var="relatedProduct" items="${relatedProducts}">
                <div class="col">
                    <div class="card h-100 shadow-sm">
                        <div class="product-img-wrap">
                            <a href="${pageContext.request.contextPath}/product-details?id=${relatedProduct.productId}">
                                <c:choose>
                                    <c:when test="${not empty relatedProduct.imageUrl and (relatedProduct.imageUrl.startsWith('http://') or relatedProduct.imageUrl.startsWith('https://'))}">
                                        <img src="${relatedProduct.imageUrl}" alt="${relatedProduct.productName}">
                                    </c:when>
                                    <c:when test="${not empty relatedProduct.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/images/${relatedProduct.imageUrl}" alt="${relatedProduct.productName}">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/images/no-image.jpg" alt="No Image">
                                    </c:otherwise>
                                </c:choose>
                            </a>
                        </div>
                        <div class="card-body">
                            <p class="text-primary small mb-1">${relatedProduct.brandName}</p>
                            <h6 class="card-title mb-1">
                                <a href="${pageContext.request.contextPath}/product-details?id=${relatedProduct.productId}" class="text-dark text-decoration-none">
                                    ${relatedProduct.productName}
                                </a>
                            </h6>
                            <p class="product-price mb-0">
                                <fmt:formatNumber value="${relatedProduct.price}" type="currency" currencySymbol="$"/>
                            </p>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<%@ include file="includes/footer.jsp" %>
