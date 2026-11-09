<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="includes/header.jsp" %>

<style>
    /* Page header row */
    .oh-header {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 24px;
    }
    .oh-header h1 { color: #2d3748; font-size: 1.6rem; font-weight: 700; }
    .oh-count {
        background: #ebf8ff; color: #2c5282; font-size: 0.85rem;
        font-weight: 600; padding: 6px 14px; border-radius: 20px;
        border: 1px solid #bee3f8;
    }

    /* Order card */
    .order-card {
        background: #fff; border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.07);
        margin-bottom: 16px; overflow: hidden;
        border: 1px solid #e2e8f0;
        transition: box-shadow 0.2s, transform 0.15s;
    }
    .order-card:hover {
        box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        transform: translateY(-1px);
    }

    /* Card top bar */
    .order-card-top {
        display: flex; justify-content: space-between; align-items: center;
        padding: 14px 20px;
        background: #f7fafc;
        border-bottom: 1px solid #e2e8f0;
    }
    .order-id { font-weight: 700; color: #2d3748; font-size: 1rem; }
    .order-id span { color: #3182ce; }
    .order-date { color: #718096; font-size: 0.82rem; margin-top: 2px; }

    /* Status badges */
    .status-badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 5px 12px; border-radius: 20px;
        font-size: 0.78rem; font-weight: 600; white-space: nowrap;
    }
    .status-badge::before {
        content: ''; width: 7px; height: 7px; border-radius: 50%;
        background: currentColor; display: inline-block;
    }
    .status-pending   { background: #fefcbf; color: #975a16; border: 1px solid #f6e05e; }
    .status-confirmed { background: #bee3f8; color: #2c5282; border: 1px solid #90cdf4; }
    .status-shipping  { background: #e9d8fd; color: #553c9a; border: 1px solid #d6bcfa; }
    .status-completed { background: #c6f6d5; color: #276749; border: 1px solid #9ae6b4; }
    .status-cancelled { background: #fed7d7; color: #c53030; border: 1px solid #feb2b2; }

    /* Card body */
    .order-card-body {
        display: grid; grid-template-columns: 1fr 1fr auto;
        gap: 16px; padding: 16px 20px; align-items: start;
    }
    @media (max-width: 680px) {
        .order-card-body { grid-template-columns: 1fr; }
    }

    .info-block .label {
        font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em;
        color: #a0aec0; font-weight: 600; margin-bottom: 4px;
    }
    .info-block .value { color: #2d3748; font-size: 0.9rem; font-weight: 500; }
    .info-block .sub   { color: #718096; font-size: 0.82rem; margin-top: 2px; }

    .order-total {
        text-align: right;
    }
    .order-total .label {
        font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em;
        color: #a0aec0; font-weight: 600; margin-bottom: 4px;
    }
    .order-total .amount {
        font-size: 1.25rem; font-weight: 700; color: #e53e3e;
    }

    /* Card footer */
    .order-card-footer {
        display: flex; justify-content: flex-end; align-items: center;
        gap: 10px; padding: 12px 20px;
        border-top: 1px solid #f0f4f8;
        background: #fafbfc;
    }

    /* Empty state */
    .empty-orders {
        text-align: center; padding: 70px 20px;
        background: #fff; border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.07);
        border: 1px solid #e2e8f0;
    }
    .empty-icon {
        width: 80px; height: 80px; border-radius: 50%;
        background: #ebf8ff; color: #3182ce;
        font-size: 2rem; font-weight: 700;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 20px;
    }
    .empty-orders h3 { color: #2d3748; font-size: 1.3rem; margin-bottom: 8px; }
    .empty-orders p  { color: #718096; margin-bottom: 24px; }

    /* Alert fix for this page */
    .oh-alert { margin-bottom: 20px; }
</style>

<div class="container">

    <c:if test="${not empty param.message}">
        <div class="alert alert-success oh-alert">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-error oh-alert">${param.error}</div>
    </c:if>

    <div class="oh-header">
        <h1>My Orders</h1>
        <c:if test="${not empty orders}">
            <span class="oh-count">${fn:length(orders)} order<c:if test="${fn:length(orders) != 1}">s</c:if></span>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${not empty orders}">
            <c:forEach var="order" items="${orders}">
                <div class="order-card">
                    <!-- Top bar: order id + date | status -->
                    <div class="order-card-top">
                        <div>
                            <div class="order-id">Order <span>#${order.orderId}</span></div>
                            <div class="order-date">
                                <c:choose><c:when test="${not empty order.orderDate}"><fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy  HH:mm"/></c:when><c:otherwise><span class="text-muted">Not recorded</span></c:otherwise></c:choose>
                            </div>
                        </div>
                        <span class="status-badge status-${order.status.toLowerCase()}">${order.status}</span>
                    </div>

                    <!-- Body: receiver | address | total -->
                    <div class="order-card-body">
                        <div class="info-block">
                            <div class="label">Receiver</div>
                            <div class="value">${order.receiverName}</div>
                            <div class="sub">${order.receiverPhone}</div>
                        </div>
                        <div class="info-block">
                            <div class="label">Delivery Address</div>
                            <div class="value">${order.receiverAddress}</div>
                            <c:if test="${not empty order.note}">
                                <div class="sub">Note: ${order.note}</div>
                            </c:if>
                        </div>
                        <div class="order-total">
                            <div class="label">Total</div>
                            <div class="amount">
                                <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="$"/>
                            </div>
                        </div>
                    </div>

                    <!-- Footer: actions -->
                    <div class="order-card-footer">
                        <c:if test="${order.canCancel()}">
                            <form method="post" action="${pageContext.request.contextPath}/order?action=cancel"
                                  onsubmit="return confirm('Cancel this order?');">
                                <input type="hidden" name="orderId" value="${order.orderId}">
                                <button type="submit" class="btn btn-small btn-danger">Cancel Order</button>
                            </form>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/order?action=detail&id=${order.orderId}"
                           class="btn btn-small btn-primary">View Details</a>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-orders">
                <div class="empty-icon">&#128722;</div>
                <h3>No orders yet</h3>
                <p>You haven't placed any orders. Start exploring our products!</p>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Start Shopping</a>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<%@ include file="includes/footer.jsp" %>
