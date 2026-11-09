<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <h2 class="mb-4">Shopping Cart</h2>

    <c:if test="${not empty cartNotice}"><div class="alert alert-warning"><c:out value="${cartNotice}"/></div></c:if>
    <c:if test="${not empty param.message}">
        <div class="alert alert-success">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger">${param.error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty sessionScope.cart and sessionScope.cart.totalItems > 0}">
            <div class="row g-4">
                <!-- Cart Items Table -->
                <div class="col-lg-8">
                    <div class="card shadow-sm">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Product</th>
                                            <th>Price</th>
                                            <th>Quantity</th>
                                            <th>Total</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${sessionScope.cart.items}">
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center gap-3">
                                                        <c:choose>
                                                            <c:when test="${not empty item.product.imageUrl and (item.product.imageUrl.startsWith('http://') or item.product.imageUrl.startsWith('https://'))}">
                                                                <img src="${item.product.imageUrl}" alt="${item.product.productName}" class="cart-product-image">
                                                            </c:when>
                                                            <c:when test="${not empty item.product.imageUrl}">
                                                                <img src="${pageContext.request.contextPath}/images/${item.product.imageUrl}" alt="${item.product.productName}" class="cart-product-image">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img src="${pageContext.request.contextPath}/images/no-image.jpg" alt="No Image" class="cart-product-image">
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <div>
                                                            <a href="${pageContext.request.contextPath}/product-details?id=${item.product.productId}" class="fw-medium text-dark text-decoration-none">
                                                                ${item.product.productName}
                                                            </a>
                                                            <p class="text-muted small mb-0">${item.product.brandName}</p>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-nowrap">
                                                    <fmt:formatNumber value="${item.product.price}" type="currency" currencySymbol="$"/>
                                                </td>
                                                <td>
                                                    <form method="post" action="${pageContext.request.contextPath}/cart?action=update" class="d-flex align-items-center gap-2">
                                                        <input type="hidden" name="productId" value="${item.product.productId}">
                                                        <input type="number" name="quantity" value="${item.quantity}"
                                                               min="1" max="${item.product.quantity}"
                                                               class="form-control form-control-sm" style="width: 70px;">
                                                        <button type="submit" class="btn btn-outline-secondary btn-sm">Update</button>
                                                    </form>
                                                </td>
                                                <td class="text-nowrap fw-medium product-price">
                                                    <fmt:formatNumber value="${item.lineTotal}" type="currency" currencySymbol="$"/>
                                                </td>
                                                <td>
                                                    <form method="post" action="${pageContext.request.contextPath}/cart?action=remove">
                                                        <input type="hidden" name="productId" value="${item.product.productId}">
                                                        <button type="submit" class="btn btn-outline-danger btn-sm">Remove</button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Order Summary -->
                <div class="col-lg-4">
                    <div class="card shadow-sm" style="position: sticky; top: 80px;">
                        <div class="card-header fw-semibold">Order Summary</div>
                        <div class="card-body">
                            <div class="d-flex justify-content-between mb-2">
                                <span>Total Items:</span>
                                <span>${sessionScope.cart.totalItems}</span>
                            </div>
                            <hr>
                            <div class="d-flex justify-content-between mb-3">
                                <span class="fw-bold">Total Amount:</span>
                                <span class="fw-bold product-price">
                                    <fmt:formatNumber value="${sessionScope.cart.totalAmount}" type="currency" currencySymbol="$"/>
                                </span>
                            </div>
                            <div class="d-grid gap-2">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.LOGIN_USER}">
                                        <a href="${pageContext.request.contextPath}/order?action=checkout" class="btn btn-primary">Proceed to Checkout</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/auth?action=login&redirect=${pageContext.request.contextPath}/order?action=checkout" class="btn btn-primary">Login to Checkout</a>
                                    </c:otherwise>
                                </c:choose>
                                <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary">Continue Shopping</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card text-center p-5 shadow-sm">
                <h4 class="mb-2">Your cart is empty</h4>
                <p class="text-muted mb-4">Add some products to your cart to get started.</p>
                <div>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Start Shopping</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="includes/footer.jsp" %>
