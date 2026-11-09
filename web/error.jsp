<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 text-center py-5">
            <div class="display-1 text-muted mb-3">&#9888;</div>
            <h2 class="mb-3">Oops! Something went wrong</h2>
            <c:choose>
                <c:when test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:when>
                <c:otherwise>
                    <p class="text-muted mb-4">We're sorry, but something unexpected happened. Please try again later.</p>
                </c:otherwise>
            </c:choose>
            <div class="d-flex gap-2 justify-content-center mt-3">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Go to Home</a>
                <button onclick="history.back()" class="btn btn-outline-secondary">Go Back</button>
            </div>
        </div>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
