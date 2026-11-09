<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="includes/header.jsp" %>
<div class="container" style="max-width:680px">
    <div class="card p-4 shadow-sm text-center">
        <h3 class="text-success mb-3">Account created successfully</h3>
        <p class="text-muted">You can now sign in to your account.</p>
        <a class="btn btn-primary mx-auto" href="${pageContext.request.contextPath}/auth?action=login">Proceed to login</a>
    </div>
</div>
<%@ include file="includes/footer.jsp" %>
