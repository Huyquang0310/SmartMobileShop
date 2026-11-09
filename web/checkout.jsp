<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <h2 class="mb-4">Checkout</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="row g-4">
        <!-- Checkout Form -->
        <div class="col-lg-8">
            <form method="post" action="${pageContext.request.contextPath}/order?action=place" onsubmit="return validateCheckoutForm()">

                <div class="card shadow-sm mb-3">
                    <div class="card-header fw-semibold">Delivery Information</div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label for="receiverName" class="form-label">Receiver Name <span class="text-danger">*</span></label>
                            <input type="text" id="receiverName" name="receiverName"
                                   value="${not empty receiverName ? receiverName : user.fullName}"
                                   required class="form-control">
                        </div>
                        <div class="mb-3">
                            <label for="receiverPhone" class="form-label">Phone Number <span class="text-danger">*</span></label>
                            <input type="text" id="receiverPhone" name="receiverPhone"
                                   value="${not empty receiverPhone ? receiverPhone : user.phone}"
                                   required pattern="(03|05|07|08|09)[0-9]{8}"
                                   title="Phone must be 10 digits starting with 03, 05, 07, 08 or 09"
                                   maxlength="10" class="form-control" placeholder="e.g. 0912345678">
                            <div class="text-danger small mt-1" id="err-receiverPhone"></div>
                        </div>
                        <div class="mb-3">
                            <label for="receiverAddress" class="form-label">Delivery Address <span class="text-danger">*</span></label>
                            <textarea id="receiverAddress" name="receiverAddress" rows="3"
                                      required class="form-control">${not empty receiverAddress ? receiverAddress : user.address}</textarea>
                        </div>
                        <div class="mb-3">
                            <label for="note" class="form-label">Order Note</label>
                            <textarea id="note" name="note" rows="2"
                                      placeholder="Any special instructions..." class="form-control">${note}</textarea>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm mb-3">
                    <div class="card-header fw-semibold">Payment Method</div>
                    <div class="card-body">
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="paymentMethod" id="cod" value="cod" checked>
                            <label class="form-check-label fw-medium" for="cod">Cash on Delivery (COD)</label>
                        </div>
                        <p class="text-muted small ms-4 mb-0">Pay when you receive your order</p>
                    </div>
                </div>

                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary">Back to Cart</a>
                    <button type="submit" class="btn btn-primary">Place Order</button>
                </div>
            </form>
        </div>

        <!-- Order Summary -->
        <div class="col-lg-4">
            <div class="card shadow-sm" style="position: sticky; top: 80px;">
                <div class="card-header fw-semibold">Order Summary</div>
                <div class="card-body">
                    <c:forEach var="item" items="${sessionScope.cart.items}">
                        <div class="d-flex justify-content-between mb-2 small">
                            <span>${item.product.productName} <span class="text-muted">x${item.quantity}</span></span>
                            <span class="text-nowrap ms-2">
                                <fmt:formatNumber value="${item.lineTotal}" type="currency" currencySymbol="$"/>
                            </span>
                        </div>
                    </c:forEach>
                    <hr>
                    <div class="d-flex justify-content-between mb-1">
                        <span>Total Items:</span>
                        <span>${sessionScope.cart.totalItems}</span>
                    </div>
                    <div class="d-flex justify-content-between fw-bold">
                        <span>Total Amount:</span>
                        <span class="product-price">
                            <fmt:formatNumber value="${sessionScope.cart.totalAmount}" type="currency" currencySymbol="$"/>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function validateCheckoutForm() {
    var errPhone = document.getElementById('err-receiverPhone');
    if (errPhone) errPhone.textContent = '';
    var phone = document.getElementById('receiverPhone').value.trim();
    var phoneReg = /^(03|05|07|08|09)\d{8}$/;
    if (!phoneReg.test(phone)) {
        if (errPhone) errPhone.textContent = 'Phone must be 10 digits starting with 03, 05, 07, 08 or 09!';
        return false;
    }
    return true;
}
</script>

<%@ include file="includes/footer.jsp" %>
