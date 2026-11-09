<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <h2 class="mb-4">My Profile</h2>

    <div class="row g-4">
        <!-- Avatar Card -->
        <div class="col-md-3">
            <div class="card shadow-sm text-center p-4">
                <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center mx-auto mb-3"
                     style="width:80px; height:80px; font-size:2rem; font-weight:700;">
                    ${fn:substring(sessionScope.LOGIN_USER.fullName, 0, 1)}
                </div>
                <div class="fw-semibold">${sessionScope.LOGIN_USER.fullName}</div>
                <div class="mt-2">
                    <c:choose>
                        <c:when test="${sessionScope.LOGIN_USER.admin}">
                            <span class="badge bg-warning text-dark">Admin</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-primary">Customer</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <hr>
                <a href="${pageContext.request.contextPath}/change-password" class="small text-decoration-none">Change Password</a>
                <hr>
                <a href="${pageContext.request.contextPath}/my-qa" class="small text-decoration-none">My Q&amp;A History</a>
            </div>
        </div>

        <!-- Profile Form -->
        <div class="col-md-9">
            <div class="card shadow-sm p-4">
                <c:if test="${not empty success}">
                    <div class="alert alert-success">${success}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/profile" onsubmit="return validateProfile()">
                    <div class="mb-3">
                        <label class="form-label">Username</label>
                        <input type="text" value="${sessionScope.LOGIN_USER.username}" class="form-control" disabled>
                    </div>
                    <div class="mb-3">
                        <label for="fullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                        <input type="text" id="fullName" name="fullName"
                               value="${sessionScope.LOGIN_USER.fullName}" required class="form-control">
                        <div class="text-danger small mt-1" id="err-fullName"></div>
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                        <input type="email" id="email" name="email"
                               value="${sessionScope.LOGIN_USER.email}" required class="form-control">
                        <div class="text-danger small mt-1" id="err-email"></div>
                    </div>
                    <div class="mb-3">
                        <label for="phone" class="form-label">Phone</label>
                        <input type="text" id="phone" name="phone"
                               value="${sessionScope.LOGIN_USER.phone}" class="form-control"
                               maxlength="10" pattern="(03|05|07|08|09)[0-9]{8}" inputmode="numeric" placeholder="e.g. 0912345678">
                        <div class="text-danger small mt-1" id="err-phone"></div>
                    </div>
                    <div class="mb-3">
                        <label for="address" class="form-label">Address</label>
                        <textarea id="address" name="address" rows="3" class="form-control">${sessionScope.LOGIN_USER.address}</textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function validateProfile() {
    var ok = true;
    document.getElementById('err-fullName').textContent = '';
    document.getElementById('err-email').textContent = '';
    document.getElementById('err-phone').textContent = '';

    var name = document.getElementById('fullName').value.trim();
    if (!name) { document.getElementById('err-fullName').textContent = 'Full name is required'; ok = false; }

    var email = document.getElementById('email').value.trim();
    var emailReg = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email) { document.getElementById('err-email').textContent = 'Email is required'; ok = false; }
    else if (!emailReg.test(email)) { document.getElementById('err-email').textContent = 'Invalid email format'; ok = false; }

    var phone = document.getElementById('phone').value.trim();
    var phoneReg = /^(03|05|07|08|09)\d{8}$/;
    if (phone && !phoneReg.test(phone)) {
        document.getElementById('err-phone').textContent = 'Phone must be 10 digits and start with 03, 05, 07, 08, or 09';
        ok = false;
    }
    return ok;
}
</script>

<%@ include file="includes/footer.jsp" %>
