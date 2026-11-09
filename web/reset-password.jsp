<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="includes/header.jsp" %>
<div class="container" style="max-width:540px">
    <div class="card p-4 shadow-sm border-0">
        <h3 class="mb-2">Set a new password</h3>
        <c:if test="${not empty error}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
        <form method="post" action="${pageContext.request.contextPath}/reset-password">
            <div class="mb-3">
                <label for="newPassword" class="form-label">New password</label>
                <input class="form-control" type="password" id="newPassword" name="newPassword" minlength="8" maxlength="100" autocomplete="new-password" required>
            </div>
            <div class="mb-3">
                <label for="confirmPassword" class="form-label">Confirm new password</label>
                <input class="form-control" type="password" id="confirmPassword" name="confirmPassword" minlength="8" maxlength="100" autocomplete="new-password" required>
            </div>
            <button class="btn btn-primary" type="submit">Update password</button>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/forgot-password">Back</a>
        </form>
    </div>
</div>
<%@ include file="includes/footer.jsp" %>
