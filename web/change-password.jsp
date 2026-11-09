<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm p-4">
                <h4 class="mb-4 pb-2 border-bottom">Change Password</h4>

                <c:if test="${not empty success}">
                    <div class="alert alert-success">${success}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/change-password" onsubmit="return validateForm()">
                    <div class="mb-3">
                        <label for="oldPassword" class="form-label">Current Password <span class="text-danger">*</span></label>
                        <input type="password" id="oldPassword" name="oldPassword" required class="form-control" placeholder="Enter current password">
                        <div class="text-danger small mt-1" id="err-old"></div>
                    </div>
                    <div class="mb-3">
                        <label for="newPassword" class="form-label">New Password <span class="text-danger">*</span></label>
                        <input type="password" id="newPassword" name="newPassword" required class="form-control" placeholder="At least 6 characters">
                        <div class="text-danger small mt-1" id="err-new"></div>
                    </div>
                    <div class="mb-3">
                        <label for="confirmPassword" class="form-label">Confirm New Password <span class="text-danger">*</span></label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required class="form-control" placeholder="Re-enter new password">
                        <div class="text-danger small mt-1" id="err-confirm"></div>
                    </div>
                    <div class="d-flex gap-2 mt-4">
                        <a href="${pageContext.request.contextPath}/profile" class="btn btn-outline-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Change Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function validateForm() {
    var ok = true;
    ['err-old','err-new','err-confirm'].forEach(function(id) {
        document.getElementById(id).textContent = '';
    });
    if (!document.getElementById('oldPassword').value) {
        document.getElementById('err-old').textContent = 'Current password is required'; ok = false;
    }
    var np = document.getElementById('newPassword').value;
    if (!np) { document.getElementById('err-new').textContent = 'New password is required'; ok = false; }
    else if (np.length < 6) { document.getElementById('err-new').textContent = 'Password must be at least 6 characters'; ok = false; }
    var cp = document.getElementById('confirmPassword').value;
    if (!cp) { document.getElementById('err-confirm').textContent = 'Please confirm your new password'; ok = false; }
    else if (np !== cp) { document.getElementById('err-confirm').textContent = 'Passwords do not match'; ok = false; }
    return ok;
}
</script>

<%@ include file="includes/footer.jsp" %>
