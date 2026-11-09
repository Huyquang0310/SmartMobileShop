<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Brand Management" scope="request"/>
<c:set var="activePage" value="brands" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <div class="content-header">
        <span>${totalItems} brands</span>
        <a href="${pageContext.request.contextPath}/admin/brands?action=form" class="btn btn-primary">+ Add Brand</a>
    </div>

    <c:if test="${not empty param.message}">
        <div class="alert alert-success">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="alert alert-error">${param.error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty brands}">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Brand Name</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="brand" items="${brands}">
                        <tr>
                            <td>${brand.brandId}</td>
                            <td>${brand.brandName}</td>
                            <td><span class="status ${brand.status ? 'active' : 'inactive'}">${brand.status ? 'Active' : 'Inactive'}</span></td>
                            <td class="actions">
                                <a href="${pageContext.request.contextPath}/admin/brands?action=edit&id=${brand.brandId}" class="btn btn-small btn-primary">Edit</a>
                                <a href="${pageContext.request.contextPath}/admin/brands?action=delete&id=${brand.brandId}" class="btn btn-small btn-danger" onclick="return confirm('Are you sure?')">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
            <c:set var="paginationBaseUrl" value="${pageContext.request.contextPath}/admin/brands?" scope="request"/>
            <%@ include file="includes/pagination.jsp" %>
        </c:when>
        <c:otherwise>
            <div class="no-data">
                <p>No brands found.</p>
                <a href="${pageContext.request.contextPath}/admin/brands?action=form" class="btn btn-primary">Add First Brand</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="includes/admin-footer.jsp" %>
