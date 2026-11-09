<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Mobile Shop</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/home.css" rel="stylesheet">
    <style>
        :root {
            --bs-primary: #ff6b6b;
            --bs-primary-rgb: 255, 107, 107;
            --bs-link-color: #ff5252;
            --bs-link-hover-color: #f44336;
        }
        body {
            background-color: #f8fafc;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            padding-top: 80px;
        }
        main { flex: 1; }
        .product-img-wrap { height: 200px; overflow: hidden; }
        .product-img-wrap img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s; }
        .card:hover .product-img-wrap img { transform: scale(1.05); }
        .product-price { color: #dc3545; font-weight: 700; font-size: 1.1rem; }
        .user-avatar {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: #dbeafe;
            border: 2px solid #ffffff;
            color: #1d4ed8;
            font-weight: 700;
            font-size: 0.875rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .role-admin { background: #fef3c7; color: #92400e; }
        .role-customer { background: #dbeafe; color: #1e40af; }
        .status-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 600;
        }
        .status-pending { background: #fefcbf; color: #975a16; border: 1px solid #f6e05e; }
        .status-confirmed { background: #bee3f8; color: #2c5282; border: 1px solid #90cdf4; }
        .status-shipping { background: #e9d8fd; color: #553c9a; border: 1px solid #d6bcfa; }
        .status-completed { background: #c6f6d5; color: #276749; border: 1px solid #9ae6b4; }
        .status-cancelled { background: #fed7d7; color: #c53030; border: 1px solid #feb2b2; }
        .table-image { width: 50px; height: 50px; object-fit: cover; border-radius: 6px; }
        .cart-product-image { width: 60px; height: 60px; object-fit: cover; border-radius: 6px; }
        .alert-error {
            --bs-alert-color: #842029;
            --bs-alert-bg: #f8d7da;
            --bs-alert-border-color: #f5c2c7;
        }
    </style>
</head>
<body>
<header>
    <nav class="navbar navbar-expand-lg navbar-light border-bottom fixed-top" style="background:#3b82f6; border-color:#2563eb !important; min-height:64px;">
        <div class="container">
            <a class="navbar-brand fw-semibold text-white" href="${pageContext.request.contextPath}/home">Smart Mobile Shop</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar" aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="mainNavbar">
                <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-2">
                    <li class="nav-item">
                        <a class="nav-link text-white" href="${pageContext.request.contextPath}/home">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white" href="${pageContext.request.contextPath}/cart">
                            Cart
                            <c:if test="${not empty sessionScope.cart and sessionScope.cart.totalItems > 0}">
                                <span class="badge text-bg-light ms-1">${sessionScope.cart.totalItems}</span>
                            </c:if>
                        </a>
                    </li>

                    <c:choose>
                        <c:when test="${not empty sessionScope.LOGIN_USER}">
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle d-flex align-items-center gap-2 text-white" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span class="user-avatar">${fn:substring(sessionScope.LOGIN_USER.fullName, 0, 1)}</span>
                                    <span class="d-none d-lg-inline">${sessionScope.LOGIN_USER.fullName}</span>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                    <li class="px-3 py-2 border-bottom">
                                        <div class="fw-semibold">${sessionScope.LOGIN_USER.fullName}</div>
                                        <span class="badge ${sessionScope.LOGIN_USER.admin ? 'role-admin' : 'role-customer'} mt-1">
                                            ${sessionScope.LOGIN_USER.admin ? 'Admin' : 'Customer'}
                                        </span>
                                    </li>
                                    <c:if test="${sessionScope.LOGIN_USER.admin}">
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard">Admin Dashboard</a></li>
                                        <li><hr class="dropdown-divider"></li>
                                    </c:if>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/order?action=history">My Orders</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/my-qa">My Q&amp;A</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">My Profile</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/change-password">Change Password</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth?action=logout">Logout</a></li>
                                </ul>
                            </li>
                        </c:when>
                        <c:otherwise>
                            <li class="nav-item"><a class="nav-link text-white" href="${pageContext.request.contextPath}/auth?action=login">Login</a></li>
                            <li class="nav-item"><a class="nav-link text-white" href="${pageContext.request.contextPath}/auth?action=register">Register</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>
    </nav>
</header>

<main class="py-4">
