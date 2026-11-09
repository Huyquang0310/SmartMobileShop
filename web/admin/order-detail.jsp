<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Order #${order.orderId}" scope="request"/>
<c:set var="activePage" value="orders" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<c:if test="${not empty param.message}">
    <div class="alert alert-success">${param.message}</div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="alert alert-error">${param.error}</div>
</c:if>

<!-- Order Info Cards -->
<div class="order-info-section">
    <div class="info-card">
        <h3>Order Information</h3>
        <div class="info-row">
            <span class="label">Order Date:</span>
            <span class="value"><c:choose><c:when test="${not empty order.orderDate}"><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/></c:when><c:otherwise><span class="text-muted">Not recorded</span></c:otherwise></c:choose></span>
        </div>
        <div class="info-row">
            <span class="label">Customer ID:</span>
            <span class="value">#${order.userId}</span>
        </div>
        <div class="info-row">
            <span class="label">Total Amount:</span>
            <span class="value"><strong><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="$"/></strong></span>
        </div>
        <div class="info-row">
            <span class="label">Status:</span>
            <span class="value"><span class="status status-${order.status.toLowerCase()}">${order.status}</span></span>
        </div>
    </div>

    <div class="info-card">
        <h3>Delivery Information</h3>
        <div class="info-row">
            <span class="label">Receiver:</span>
            <span class="value">${order.receiverName}</span>
        </div>
        <div class="info-row">
            <span class="label">Phone:</span>
            <span class="value">${order.receiverPhone}</span>
        </div>
        <div class="info-row">
            <span class="label">Address:</span>
            <span class="value">${order.receiverAddress}</span>
        </div>
        <c:if test="${not empty order.note}">
            <div class="info-row">
                <span class="label">Note:</span>
                <span class="value">${order.note}</span>
            </div>
        </c:if>
    </div>

    <div class="info-card">
        <h3>Update Status</h3>
        <c:choose>
            <c:when test="${canUpdateStatus}">
                <form method="post" action="${pageContext.request.contextPath}/admin/orders?action=update-status" class="status-form">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <div class="form-group" style="display:flex; gap:8px; align-items:center;">
                        <select name="status" class="form-control">
                            <c:forEach var="s" items="${allowedNextStatuses}">
                                <option value="${s}">${s}</option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn btn-primary">Update</button>
                    </div>
                    <small class="text-muted">Current: ${order.status}</small>
                </form>
            </c:when>
            <c:otherwise>
                <p class="text-muted" style="margin: 0;">Order status is final (${order.status}) and cannot be updated.</p>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Order Items -->
<div class="content-card">
    <h3 style="margin-bottom:15px; color:#1e293b;">Order Items</h3>
    <table class="order-items-table">
        <thead>
            <tr>
                <th>Product</th>
                <th>Unit Price</th>
                <th>Quantity</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="detail" items="${order.orderDetails}">
                <tr>
                    <td>${detail.productName}</td>
                    <td><fmt:formatNumber value="${detail.unitPrice}" type="currency" currencySymbol="$"/></td>
                    <td>${detail.quantity}</td>
                    <td><fmt:formatNumber value="${detail.lineTotal}" type="currency" currencySymbol="$"/></td>
                </tr>
            </c:forEach>
        </tbody>
        <tfoot>
            <tr class="total-row">
                <td colspan="3"><strong>Total Amount:</strong></td>
                <td><strong><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="$"/></strong></td>
            </tr>
        </tfoot>
    </table>

    <div style="margin-top:20px;">
        <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary">Back to Orders</a>
    </div>
</div>

<%@ include file="includes/admin-footer.jsp" %>
