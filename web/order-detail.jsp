<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="includes/header.jsp" %>

<style>
    /* Back link */
    .od-back { margin-bottom: 18px; }
    .od-back a {
        color: #3182ce; text-decoration: none; font-size: 0.88rem;
        font-weight: 500; display: inline-flex; align-items: center; gap: 5px;
    }
    .od-back a:hover { color: #2c5282; }

    /* Order title bar */
    .od-title-bar {
        background: #fff; border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 2px 10px rgba(0,0,0,0.06);
        padding: 20px 24px;
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 20px;
    }
    .od-title-bar .order-num {
        font-size: 1.4rem; font-weight: 700; color: #2d3748;
    }
    .od-title-bar .order-num span { color: #3182ce; }
    .od-title-bar .order-placed {
        color: #718096; font-size: 0.85rem; margin-top: 4px;
    }

    /* Status badges */
    .status-badge {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 6px 14px; border-radius: 20px;
        font-size: 0.8rem; font-weight: 600; white-space: nowrap;
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

    /* Info cards grid */
    .od-info-grid {
        display: grid; grid-template-columns: 1fr 1fr;
        gap: 16px; margin-bottom: 20px;
    }
    @media (max-width: 640px) { .od-info-grid { grid-template-columns: 1fr; } }

    .od-card {
        background: #fff; border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        overflow: hidden;
    }
    .od-card-header {
        background: #f7fafc; border-bottom: 1px solid #e2e8f0;
        padding: 12px 20px;
        font-weight: 600; color: #2d3748; font-size: 0.9rem;
        text-transform: uppercase; letter-spacing: 0.04em;
    }
    .od-card-body { padding: 16px 20px; }

    .od-row {
        display: flex; justify-content: space-between;
        align-items: flex-start; padding: 9px 0;
        border-bottom: 1px solid #f0f4f8;
        gap: 12px;
    }
    .od-row:last-child { border-bottom: none; }
    .od-row .lbl {
        color: #718096; font-size: 0.85rem;
        white-space: nowrap; flex-shrink: 0;
    }
    .od-row .val {
        color: #2d3748; font-size: 0.88rem;
        font-weight: 500; text-align: right;
    }

    /* Items table */
    .od-items-card {
        background: #fff; border-radius: 12px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        overflow: hidden; margin-bottom: 20px;
    }
    .od-items-card .od-card-header { font-size: 0.9rem; }

    .od-table { width: 100%; border-collapse: collapse; }
    .od-table thead tr { background: #f7fafc; }
    .od-table th {
        padding: 11px 20px; text-align: left;
        color: #718096; font-size: 0.78rem; font-weight: 600;
        text-transform: uppercase; letter-spacing: 0.05em;
        border-bottom: 1px solid #e2e8f0;
    }
    .od-table th:not(:first-child) { text-align: right; }
    .od-table td {
        padding: 14px 20px; border-bottom: 1px solid #f0f4f8;
        font-size: 0.9rem; color: #4a5568;
    }
    .od-table td:not(:first-child) { text-align: right; }
    .od-table tbody tr:last-child td { border-bottom: none; }
    .od-table tbody tr:hover { background: #fafbfc; }
    .od-table .product-col {
        color: #2d3748; font-weight: 600;
    }
    .od-table .price-col { color: #4a5568; }
    .od-table .qty-col {
        display: inline-flex; justify-content: flex-end;
    }
    .qty-badge {
        display: inline-block;
        background: #ebf8ff; color: #2c5282;
        padding: 2px 10px; border-radius: 12px;
        font-size: 0.82rem; font-weight: 600;
    }

    /* Table footer total */
    .od-table-total td {
        background: #f7fafc; border-top: 2px solid #e2e8f0;
        font-weight: 700; color: #2d3748;
        border-bottom: none;
    }
    .od-table-total .total-label { color: #4a5568; }
    .od-table-total .total-amount { color: #e53e3e; font-size: 1.1rem; }

    /* Action row */
    .od-actions {
        display: flex; justify-content: space-between; align-items: center;
        gap: 12px;
    }
</style>

<div class="container">

    <c:if test="${not empty param.message}">
        <div class="alert alert-success">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-error">${param.error}</div>
    </c:if>

    <!-- Back link -->
    <div class="od-back">
        <a href="${pageContext.request.contextPath}/order?action=history">&#8592; Back to My Orders</a>
    </div>

    <!-- Order title bar -->
    <div class="od-title-bar">
        <div>
            <div class="order-num">Order <span>#${order.orderId}</span></div>
            <div class="order-placed">
                Placed on <c:choose><c:when test="${not empty order.orderDate}"><fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy  HH:mm"/></c:when><c:otherwise><span class="text-muted">Not recorded</span></c:otherwise></c:choose>
            </div>
        </div>
        <span class="status-badge status-${order.status.toLowerCase()}">${order.status}</span>
    </div>

    <!-- Info cards -->
    <div class="od-info-grid">
        <!-- Order info -->
        <div class="od-card">
            <div class="od-card-header">Order Information</div>
            <div class="od-card-body">
                <div class="od-row">
                    <span class="lbl">Order Date</span>
                    <span class="val"><c:choose><c:when test="${not empty order.orderDate}"><fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy HH:mm"/></c:when><c:otherwise><span class="text-muted">Not recorded</span></c:otherwise></c:choose></span>
                </div>
                <div class="od-row">
                    <span class="lbl">Status</span>
                    <span class="val">
                        <span class="status-badge status-${order.status.toLowerCase()}">${order.status}</span>
                    </span>
                </div>
                <div class="od-row">
                    <span class="lbl">Total Amount</span>
                    <span class="val" style="color:#e53e3e; font-size:1rem;">
                        <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="$"/>
                    </span>
                </div>
            </div>
        </div>

        <!-- Delivery info -->
        <div class="od-card">
            <div class="od-card-header">Delivery Information</div>
            <div class="od-card-body">
                <div class="od-row">
                    <span class="lbl">Receiver</span>
                    <span class="val">${order.receiverName}</span>
                </div>
                <div class="od-row">
                    <span class="lbl">Phone</span>
                    <span class="val">${order.receiverPhone}</span>
                </div>
                <div class="od-row">
                    <span class="lbl">Address</span>
                    <span class="val">${order.receiverAddress}</span>
                </div>
                <c:if test="${not empty order.note}">
                    <div class="od-row">
                        <span class="lbl">Note</span>
                        <span class="val">${order.note}</span>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Order items -->
    <div class="od-items-card">
        <div class="od-card-header">Order Items</div>
        <table class="od-table">
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Unit Price</th>
                    <th>Qty</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="detail" items="${order.orderDetails}">
                    <tr>
                        <td class="product-col">${detail.productName}</td>
                        <td class="price-col">
                            <fmt:formatNumber value="${detail.unitPrice}" type="currency" currencySymbol="$"/>
                        </td>
                        <td><span class="qty-badge">x${detail.quantity}</span></td>
                        <td style="font-weight:600; color:#2d3748;">
                            <fmt:formatNumber value="${detail.lineTotal}" type="currency" currencySymbol="$"/>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
            <tfoot>
                <tr class="od-table-total">
                    <td colspan="3" class="total-label">Order Total</td>
                    <td class="total-amount">
                        <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="$"/>
                    </td>
                </tr>
            </tfoot>
        </table>
    </div>

    <!-- Actions -->
    <div class="od-actions">
        <a href="${pageContext.request.contextPath}/order?action=history" class="btn btn-secondary">&#8592; Back to My Orders</a>
        <c:if test="${order.canCancel()}">
            <form method="post" action="${pageContext.request.contextPath}/order?action=cancel"
                  onsubmit="return confirm('Are you sure you want to cancel this order?');">
                <input type="hidden" name="orderId" value="${order.orderId}">
                <button type="submit" class="btn btn-danger">Cancel Order</button>
            </form>
        </c:if>
    </div>

</div>

<%@ include file="includes/footer.jsp" %>
