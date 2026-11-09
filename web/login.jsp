<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Smart Mobile Shop</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { min-height: 100vh; }
        .auth-image {
            background: linear-gradient(135deg, rgba(44,82,130,0.9), rgba(49,130,206,0.85)),
                        url('https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800') center/cover;
            min-height: 100vh;
        }
    </style>
</head>
<body>
<div class="row g-0 min-vh-100">
    <!-- Left image panel -->
    <div class="col-lg-6 auth-image d-none d-lg-flex flex-column justify-content-center align-items-center p-5 text-white">
        <h1 class="fs-2 fw-bold mb-3 text-center">Welcome Back!</h1>
        <p class="text-center opacity-90" style="max-width:350px; line-height:1.6;">
            Access your account to explore the latest smartphones and manage your orders.
        </p>
    </div>

    <!-- Right form panel -->
    <div class="col-lg-6 d-flex align-items-center justify-content-center p-4 bg-light">
        <div style="width:100%; max-width:400px;">
            <div class="text-center mb-4">
                <a href="${pageContext.request.contextPath}/" class="text-primary fw-bold fs-5 text-decoration-none">
                    Smart Mobile Shop
                </a>
            </div>

            <div class="card shadow-sm border-0 p-4">
                <h2 class="text-center mb-4 fs-5 fw-bold text-dark">Sign In</h2>

                <c:if test="${param.reset == 'success'}"><div class="alert alert-success">Password updated. You can sign in now.</div></c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="alert alert-success">${success}</div>
                </c:if>
                <c:if test="${not empty info}">
                    <div class="alert alert-info">${info}</div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/auth?action=login">
                    <input type="hidden" name="redirect" value="<c:out value='${param.redirect}'/>">
                    <div class="mb-3">
                        <label for="username" class="form-label fw-medium small">Username</label>
                        <input type="text" id="username" name="usernameOrEmail"
                               value="${usernameOrEmail}" required class="form-control"
                               placeholder="Enter your username" autofocus>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label fw-medium small">Password</label>
                        <input type="password" id="password" name="password" required class="form-control"
                               placeholder="Enter your password">
                    </div>
                    <div class="d-grid mt-4">
                        <button type="submit" class="btn btn-primary fw-semibold">Login</button>
                    </div>
                </form>

                <div class="text-center mt-3"><a href="${pageContext.request.contextPath}/forgot-password" class="text-primary">Forgot your password?</a></div>
                <div class="text-center mt-4 pt-3 border-top">
                    <p class="text-muted small mb-0">
                        Don't have an account?
                        <a href="${pageContext.request.contextPath}/auth?action=register" class="text-primary fw-medium">Register here</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
