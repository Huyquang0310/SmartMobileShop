<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Order Management" scope="request"/>
<c:set var="activePage" value="orders" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <form class="d-flex gap-2 align-items-end flex-wrap mb-3" method="get" action="${pageContext.request.contextPath}/admin/orders">
        <div><label for="orderStatus" class="form-label">Filter by status</label>
            <select id="orderStatus" name="status" class="form-select">
                <option value="">All orders</option>
                <option value="Pending" ${selectedStatus == 'Pending' ? 'selected' : ''}>Pending</option>
                <option value="Confirmed" ${selectedStatus == 'Confirmed' ? 'selected' : ''}>Confirmed</option>
                <option value="Shipping" ${selectedStatus == 'Shipping' ? 'selected' : ''}>Shipping</option>
                <option value="Completed" ${selectedStatus == 'Completed' ? 'selected' : ''}>Completed</option>
                <option value="Cancelled" ${selectedStatus == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary">Apply</button>
        <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary">Clear</a>
    </form>
    <c:if test="${not empty param.message}">
        <div class="alert alert-success">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-error">${param.error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty orders}">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Placed At</th>
                        <th>Customer</th>
                        <th>Receiver</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="order" items="${orders}">
                        <tr>
                            <td>#${order.orderId}</td>
                            <td><c:choose><c:when test="${not empty order.orderDate}"><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/></c:when><c:otherwise><span class="text-muted">Not recorded</span></c:otherwise></c:choose></td>
                            <td>User #${order.userId}</td>
                            <td>
                                <div>${order.receiverName}</div>
                                <div class="text-muted">${order.receiverPhone}</div>
                            </td>
                            <td><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="$"/></td>
                            <td><span class="status status-${order.status.toLowerCase()}">${order.status}</span></td>
                            <td class="actions">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${order.orderId}" class="btn btn-small btn-primary">View</a>
                                <c:if test="${order.status == 'Cancelled'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders?action=delete" style="display:inline" onsubmit="return confirm('Permanently delete this cancelled order?')">
                                        <input type="hidden" name="orderId" value="${order.orderId}"><button type="submit" class="btn btn-small btn-danger">Delete</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="no-data"><p>No orders found.</p></div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="includes/admin-footer.jsp" %>
