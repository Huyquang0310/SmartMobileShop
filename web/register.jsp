<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Smart Mobile Shop</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .auth-image {
            background: linear-gradient(135deg, rgba(44,82,130,0.9), rgba(49,130,206,0.85)),
                        url('https://images.unsplash.com/photo-1556656793-08538906a9f8?w=800') center/cover;
        }
    </style>
</head>
<body>
<div class="row g-0 min-vh-100">
    <!-- Left image panel -->
    <div class="col-lg-5 auth-image d-none d-lg-flex flex-column justify-content-center align-items-center p-5 text-white">
        <h1 class="fs-2 fw-bold mb-3 text-center">Join Us Today!</h1>
        <p class="text-center opacity-90" style="max-width:320px; line-height:1.6;">
            Create an account to enjoy exclusive deals, fast checkout, and order tracking.
        </p>
    </div>

    <!-- Right form panel -->
    <div class="col-lg-7 d-flex align-items-center justify-content-center p-4 bg-light overflow-auto">
        <div style="width:100%; max-width:460px;">
            <div class="text-center mb-3">
                <a href="${pageContext.request.contextPath}/" class="text-primary fw-bold fs-5 text-decoration-none">
                    Smart Mobile Shop
                </a>
            </div>

            <div class="card shadow-sm border-0 p-4">
                <h2 class="text-center mb-4 fs-5 fw-bold text-dark">Create Account</h2>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/auth?action=register" onsubmit="return validateRegisterForm()">
                    <div class="mb-3">
                        <label for="fullName" class="form-label fw-medium small">Full Name <span class="text-danger">*</span></label>
                        <input type="text" id="fullName" name="fullName"
                               value="${fullName}" required class="form-control"
                               placeholder="Enter your full name">
                    </div>
                    <div class="mb-3">
                        <label for="username" class="form-label fw-medium small">Username <span class="text-danger">*</span></label>
                        <input type="text" id="username" name="username"
                               value="${username}" required class="form-control"
                               placeholder="Choose a username">
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label fw-medium small">Email <span class="text-danger">*</span></label>
                        <input type="email" id="email" name="email"
                               value="${email}" required class="form-control"
                               placeholder="Enter your email">
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label fw-medium small">Password <span class="text-danger">*</span></label>
                        <input type="password" id="password" name="password" required minlength="8" maxlength="100" class="form-control"
                               placeholder="Create a password">
                    </div>
                    <div class="mb-3">
                        <label for="confirmPassword" class="form-label fw-medium small">Confirm Password <span class="text-danger">*</span></label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required minlength="8" maxlength="100" class="form-control"
                               placeholder="Confirm your password">
                    </div>
                    <div class="mb-3">
                        <label for="phone" class="form-label fw-medium small">Phone</label>
                        <input type="text" id="phone" name="phone"
                               value="${phone}" class="form-control" maxlength="10" inputmode="numeric"
                               pattern="(03|05|07|08|09)[0-9]{8}"
                               placeholder="Phone number (optional)">
                        <div id="err-phone" class="text-danger small mt-1"></div>
                    </div>
                    <div class="mb-3">
                        <label for="address" class="form-label fw-medium small">Address</label>
                        <textarea id="address" name="address" rows="2" class="form-control"
                                  placeholder="Your address (optional)">${address}</textarea>
                    </div>
                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary fw-semibold">Register</button>
                    </div>
                </form>

                <div class="text-center mt-3 pt-3 border-top">
                    <p class="text-muted small mb-0">
                        Already have an account?
                        <a href="${pageContext.request.contextPath}/auth?action=login" class="text-primary fw-medium">Login here</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function validateRegisterForm() {
        var errPhone = document.getElementById('err-phone');
        if (errPhone) errPhone.textContent = '';
        var phone = document.getElementById('phone').value.trim();
        var phoneRegex = /^(03|05|07|08|09)\d{8}$/;
        if (phone && !phoneRegex.test(phone)) {
            if (errPhone) errPhone.textContent = 'Phone must be 10 digits and start with 03, 05, 07, 08, or 09';
            return false;
        }
        return true;
    }
</script>
</body>
</html>
