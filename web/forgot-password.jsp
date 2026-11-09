<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="includes/header.jsp" %>
<div class="container" style="max-width:540px">
    <div class="card p-4 shadow-sm border-0">
        <h3 class="mb-2">Forgot password?</h3>
        <p class="text-muted">Confirm your account details to create a new password.</p>
        <c:if test="${param.expired == '1'}"><div class="alert alert-warning">Start again to reset your password.</div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
        <form method="post" action="${pageContext.request.contextPath}/forgot-password">
            <div class="mb-3">
                <label class="form-label" for="username">Username</label>
                <input class="form-control" id="username" name="username" maxlength="50" required autocomplete="username" value="<c:out value='${username}'/>" placeholder="Your account username">
            </div>
            <div class="mb-3">
                <label class="form-label" for="email">Registered email</label>
                <input class="form-control" id="email" type="email" name="email" maxlength="100" required autocomplete="email" value="<c:out value='${email}'/>" placeholder="you@example.com">
            </div>
            <button class="btn btn-primary" type="submit">Continue</button>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/auth?action=login">Back to login</a>
        </form>
    </div>
</div>
<%@ include file="includes/footer.jsp" %>
