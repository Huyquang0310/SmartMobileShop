<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="User Management" scope="request"/>
<c:set var="activePage" value="users" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <div class="content-header">
        <form method="get" action="${pageContext.request.contextPath}/admin/users" class="search-form">
            <input type="text" name="keyword" value="${keyword}" placeholder="Search users..." class="form-control">
            <button type="submit" class="btn btn-primary">Search</button>
            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">Clear</a>
        </form>
        <a href="${pageContext.request.contextPath}/admin/users?action=form" class="btn btn-primary">+ Add User</a>
    </div>

    <c:if test="${not empty param.message}">
        <div class="alert alert-success">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-error">${param.error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty users}">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="user" items="${users}">
                        <tr>
                            <td>${user.userId}</td>
                            <td>${user.fullName}</td>
                            <td>${user.username}</td>
                            <td>${user.email}</td>
                            <td>${user.phone}</td>
                            <td><span class="status ${user.roleId == 1 ? 'active' : ''}">${user.roleName}</span></td>
                            <td><span class="status ${user.status ? 'active' : 'inactive'}">${user.status ? 'Active' : 'Inactive'}</span></td>
                            <td class="actions">
                                <a href="${pageContext.request.contextPath}/admin/users?action=edit&id=${user.userId}" class="btn btn-small btn-primary">Edit</a>
                                <c:if test="${user.userId != sessionScope.LOGIN_USER.userId}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/users?action=update-status" style="display:inline;">
                                        <input type="hidden" name="userId" value="${user.userId}">
                                        <input type="hidden" name="status" value="${user.status ? '0' : '1'}">
                                        <button type="submit" class="btn btn-small ${user.status ? 'btn-warning' : 'btn-success'}">
                                            ${user.status ? 'Deactivate' : 'Activate'}
                                        </button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/users?action=update-role" style="display:inline;">
                                        <input type="hidden" name="userId" value="${user.userId}">
                                        <select name="roleId" onchange="this.form.submit()" class="role-select">
                                            <option value="1" ${user.roleId == 1 ? 'selected' : ''}>Admin</option>
                                            <option value="2" ${user.roleId == 2 ? 'selected' : ''}>Customer</option>
                                        </select>
                                    </form>
                                    <a href="${pageContext.request.contextPath}/admin/users?action=delete&id=${user.userId}" class="btn btn-small btn-danger" onclick="return confirm('Delete this user? This action cannot be undone.');">Delete</a>
                                </c:if>
                                <c:if test="${user.userId == sessionScope.LOGIN_USER.userId}">
                                    <span class="text-muted">Current User</span>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="no-data"><p>No users found.</p></div>
        </c:otherwise>
    </c:choose>

    <c:set var="paginationBaseUrl" value="${pageContext.request.contextPath}/admin/users?keyword=${keyword}" scope="request"/>
    <%@ include file="includes/pagination.jsp" %>
</div>

<%@ include file="includes/admin-footer.jsp" %>
