<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Dashboard" scope="request"/>
<c:set var="activePage" value="dashboard" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="stats-grid">
    <div class="stat-card"><div class="stat-info"><h3>Completed Revenue</h3><div class="stat-number"><fmt:formatNumber value="${report.totalRevenue}" type="currency" currencySymbol="$"/></div><div class="stat-detail">${report.completedOrderCount} completed orders</div></div></div>
    <div class="stat-card"><div class="stat-info"><h3>Units Sold</h3><div class="stat-number">${report.soldUnits}</div><div class="stat-detail">Completed only</div></div></div>
    <div class="stat-card"><div class="stat-info"><h3>Available Stock</h3><div class="stat-number">${sellableStockUnits}</div><div class="stat-detail">Physical stock: ${physicalStockUnits}</div></div></div>
    <div class="stat-card"><div class="stat-info"><h3>Inventory Value</h3><div class="stat-number"><fmt:formatNumber value="${inventoryValue}" type="currency" currencySymbol="$"/></div><div class="stat-detail">At listed price</div></div></div>
    <div class="stat-card"><div class="stat-info"><h3>Stock Alerts</h3><div class="stat-number">${outOfStockProducts + lowStockProducts}</div><div class="stat-detail">Out: ${outOfStockProducts} · Low (1–5): ${lowStockProducts}</div></div></div>
    <div class="stat-card"><div class="stat-info"><h3>Shop Products</h3><div class="stat-number">${activeProducts} / ${totalProducts}</div><div class="stat-detail">Hidden: ${hiddenProducts}</div></div></div>
    <div class="stat-card"><div class="stat-info"><h3>Orders</h3><div class="stat-number">${totalOrders}</div><div class="stat-detail">Pending: ${pendingOrders} · Shipping: ${shippingOrders}</div></div></div>
    <div class="stat-card"><div class="stat-info"><h3>Customers &amp; Staff</h3><div class="stat-number">${totalUsers}</div><div class="stat-detail">Registered accounts</div></div></div>
</div>

<div class="content-card">
    <h3 class="mb-3">Order Pipeline</h3>
    <p class="text-muted">Stock is reserved at checkout.</p>
    <div class="row g-3">
        <div class="col-6 col-md"><a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=Pending"><div class="p-3 rounded bg-light"><strong class="d-block fs-4">${pendingOrders}</strong><span>Pending</span></div></a></div>
        <div class="col-6 col-md"><a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=Confirmed"><div class="p-3 rounded bg-light"><strong class="d-block fs-4">${confirmedOrders}</strong><span>Confirmed</span></div></a></div>
        <div class="col-6 col-md"><a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=Shipping"><div class="p-3 rounded bg-light"><strong class="d-block fs-4">${shippingOrders}</strong><span>Shipping</span></div></a></div>
        <div class="col-6 col-md"><a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=Completed"><div class="p-3 rounded bg-light"><strong class="d-block fs-4">${completedOrders}</strong><span>Completed</span></div></a></div>
        <div class="col-6 col-md"><a class="text-decoration-none" href="${pageContext.request.contextPath}/admin/orders?status=Cancelled"><div class="p-3 rounded bg-light"><strong class="d-block fs-4">${cancelledOrders}</strong><span>Cancelled</span></div></a></div>
    </div>
</div>

<div class="content-card">
    <h3 class="mb-3">Stock Alerts</h3>
    <p class="text-muted">Low-stock items currently for sale.</p>
    <c:choose>
        <c:when test="${empty stockWarnings}"><p class="text-success">All available products are in stock.</p></c:when>
        <c:otherwise>
            <div class="table-responsive"><table class="admin-table"><thead><tr><th>Product</th><th>Brand / Category</th><th>Units Left</th><th>Action</th></tr></thead><tbody>
                <c:forEach var="p" items="${stockWarnings}">
                    <tr><td><c:out value="${p.productName}"/></td><td><c:out value="${p.brandName}"/> / <c:out value="${p.categoryName}"/></td>
                    <td><strong class="${p.quantity == 0 ? 'text-danger' : 'text-warning'}">${p.quantity}</strong></td>
                    <td><a class="btn btn-small btn-outline-primary" href="${pageContext.request.contextPath}/admin/products?action=edit&amp;id=${p.productId}">View Product</a></td></tr>
                </c:forEach>
            </tbody></table></div>
            <a class="btn btn-secondary mt-3" href="${pageContext.request.contextPath}/admin/products?stock=low">All Low-Stock Products</a>
            <a class="btn btn-outline-secondary mt-3" href="${pageContext.request.contextPath}/admin/products?stock=out">All Out-of-Stock Products</a>
        </c:otherwise>
    </c:choose>
</div>

<div class="content-card">
    <h3 class="mb-3">Sales &amp; Product Statistics</h3>
    <div class="table-responsive"><table class="admin-table">
        <thead><tr><th>Calculation</th><th>Metric</th><th>Value</th></tr></thead>
        <tbody>
            <tr><td>COUNT</td><td>Visible products</td><td>${report.productCount}</td></tr>
            <tr><td>COUNT</td><td>All orders</td><td>${report.orderCount}</td></tr>
            <tr><td>COUNT</td><td>Completed orders</td><td>${report.completedOrderCount}</td></tr>
            <tr><td>MIN</td><td>Lowest visible product price</td><td><fmt:formatNumber value="${report.minPrice}" type="currency" currencySymbol="$"/></td></tr>
            <tr><td>MAX</td><td>Highest visible product price</td><td><fmt:formatNumber value="${report.maxPrice}" type="currency" currencySymbol="$"/></td></tr>
            <tr><td>AVG</td><td>Average visible product price</td><td><fmt:formatNumber value="${report.averagePrice}" type="currency" currencySymbol="$"/></td></tr>
            <tr><td>AVG</td><td>Completed order value</td><td><fmt:formatNumber value="${averageOrderValue}" type="currency" currencySymbol="$"/></td></tr>
            <tr><td>SUM</td><td>Completed order revenue</td><td><fmt:formatNumber value="${report.totalRevenue}" type="currency" currencySymbol="$"/></td></tr>
            <tr><td>SUM</td><td>Units sold on completed orders</td><td>${report.soldUnits}</td></tr>
        </tbody>
    </table></div>
</div>

<div class="content-card">
    <h3 class="mb-3">Monthly Completed Revenue</h3>
    <div class="table-responsive"><table class="admin-table"><thead><tr><th>Month</th><th>Revenue</th></tr></thead><tbody>
        <c:forEach var="month" items="${monthlySales}">
            <tr><td>${month.key}</td><td><fmt:formatNumber value="${month.value}" type="currency" currencySymbol="$"/></td></tr>
        </c:forEach>
    </tbody></table></div>
</div>

<div class="content-card">
    <h3 class="mb-3">Recent Orders</h3>
    <div class="table-responsive"><table class="admin-table"><thead><tr><th>Order</th><th>Placed At</th><th>Total</th><th>Status</th><th></th></tr></thead><tbody>
        <c:forEach var="order" items="${recentOrders}">
            <tr><td>#${order.orderId}</td><td><c:choose><c:when test="${not empty order.orderDate}"><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/></c:when><c:otherwise><span class="text-muted">Not recorded</span></c:otherwise></c:choose></td>
                <td><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="$"/></td>
                <td>${order.status}</td>
                <td><a href="${pageContext.request.contextPath}/admin/orders?action=detail&amp;id=${order.orderId}" class="btn btn-small btn-outline-primary">View</a></td></tr>
        </c:forEach>
    </tbody></table></div>
</div>

<!-- Quick Actions -->
<div class="content-card">
    <h3 style="margin-bottom:15px; color:#1e293b;">Quick Actions</h3>
    <div style="display:flex; flex-wrap:wrap; gap:10px;">
        <a href="${pageContext.request.contextPath}/admin/products?action=form" class="btn btn-primary">+ Add Product</a>
        <a href="${pageContext.request.contextPath}/admin/brands?action=form" class="btn btn-primary">+ Add Brand</a>
        <a href="${pageContext.request.contextPath}/admin/categories?action=form" class="btn btn-primary">+ Add Category</a>
        <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary">View Orders</a>
        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">Manage Users</a>
        <a href="${pageContext.request.contextPath}/admin/qa" class="btn btn-secondary">Q&amp;A Conversations</a>
    </div>
</div>

<%@ include file="includes/admin-footer.jsp" %>
