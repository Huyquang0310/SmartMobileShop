<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="${not empty user ? 'Edit User' : 'Add New User'}" scope="request"/>
<c:set var="activePage" value="users" scope="request"/>
<%@ include file="includes/admin-header.jsp" %>

<div class="content-card">
    <div class="form-container">
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <form method="post"
              action="${pageContext.request.contextPath}/admin/users?action=${not empty user ? 'update' : 'insert'}"
              class="admin-form" onsubmit="return validateUserForm()">

            <c:if test="${not empty user}">
                <input type="hidden" name="userId" value="${user.userId}">
            </c:if>

            <div class="form-row">
                <div class="form-group">
                    <label for="fullName">Full Name <span class="required">*</span></label>
                    <input type="text" id="fullName" name="fullName"
                           value="${not empty user ? user.fullName : fullName}"
                           required class="form-control" maxlength="100" placeholder="Enter full name">
                    <div class="field-error" id="err-fullName"></div>
                </div>
                <div class="form-group">
                    <label for="username">Username <span class="required">*</span></label>
                    <input type="text" id="username" name="username"
                           value="${not empty user ? user.username : username}"
                           required class="form-control" maxlength="50" placeholder="Enter username">
                    <div class="field-error" id="err-username"></div>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="email">Email <span class="required">*</span></label>
                    <input type="email" id="email" name="email"
                           value="${not empty user ? user.email : email}"
                           required class="form-control" maxlength="100" placeholder="Enter email">
                    <div class="field-error" id="err-email"></div>
                </div>
                <div class="form-group">
                    <label for="phone">Phone</label>
                    <input type="text" id="phone" name="phone"
                           value="${not empty user ? user.phone : phone}"
                           class="form-control" maxlength="10" pattern="(03|05|07|08|09)[0-9]{8}" inputmode="numeric" placeholder="e.g. 03|05|07|08|09">
                    <div class="field-error" id="err-phone"></div>
                </div>
            </div>

            <c:if test="${empty user}">
                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Password <span class="required">*</span></label>
                        <input type="password" id="password" name="password"
                               required class="form-control" minlength="8" maxlength="100"
                               placeholder="Enter password">
                        <div class="field-error" id="err-password"></div>
                    </div>
                    <div class="form-group"></div>
                </div>
            </c:if>

            <div class="form-group">
                <label for="address">Address</label>
                <textarea id="address" name="address" rows="3" class="form-control" maxlength="255"
                          placeholder="Enter address">${not empty user ? user.address : address}</textarea>
                <div class="field-error" id="err-address"></div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="roleId">Role <span class="required">*</span></label>
                    <select id="roleId" name="roleId" required class="form-control">
                        <option value="1" ${(not empty user and user.roleId == 1) or roleId == '1' ? 'selected' : ''}>Admin</option>
                        <option value="2" ${(not empty user and user.roleId == 2) or roleId == '2' ? 'selected' : ''}>Customer</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="status">Status</label>
                    <select id="status" name="status" class="form-control">
                        <option value="1" ${(not empty user and user.status) or status == '1' or empty status ? 'selected' : ''}>Active</option>
                        <option value="0" ${(not empty user and not user.status) or status == '0' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">${not empty user ? 'Update User' : 'Add User'}</button>
            </div>
        </form>
    </div>
</div>

<script>
function validateUserForm() {
    var valid = true;
    document.querySelectorAll('.field-error').forEach(function (el) { el.textContent = ''; });

    var fullName = document.getElementById('fullName').value.trim();
    if (!fullName || fullName.length < 2 || fullName.length > 100) {
        document.getElementById('err-fullName').textContent = 'Full name must be from 2 to 100 characters';
        valid = false;
    }

    var username = document.getElementById('username').value.trim();
    if (!username || username.length < 3 || username.length > 50) {
        document.getElementById('err-username').textContent = 'Username must be from 3 to 50 characters';
        valid = false;
    }

    var email = document.getElementById('email').value.trim();
    var emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/;
    if (!emailRegex.test(email)) {
        document.getElementById('err-email').textContent = 'Email format is invalid';
        valid = false;
    }

    var phone = document.getElementById('phone').value.trim();
    var phoneRegex = /^(03|05|07|08|09)\d{8}$/;
    if (phone && !phoneRegex.test(phone)) {
        document.getElementById('err-phone').textContent = 'Phone must be 10 digits and start with 03, 05, 07, 08, or 09';
        valid = false;
    }

    var passwordInput = document.getElementById('password');
    if (passwordInput) {
        var password = passwordInput.value.trim();
        if (password.length < 8 || password.length > 100) {
            document.getElementById('err-password').textContent = 'Password must be from 8 to 100 characters';
            valid = false;
        }
    }

    var address = document.getElementById('address').value.trim();
    if (address.length > 255) {
        document.getElementById('err-address').textContent = 'Address cannot exceed 255 characters';
        valid = false;
    }

    return valid;
}
</script>

<%@ include file="includes/admin-footer.jsp" %>
