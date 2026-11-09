<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f1f5f9; }

        /* Sidebar */
        .admin-layout { display: flex; min-height: 100vh; }
        .sidebar { width: 220px; background: #1e293b; position: fixed; height: 100vh; overflow-y: auto; }
        .sidebar-header { padding: 18px 16px; border-bottom: 1px solid #334155; }
        .sidebar-header h2 { font-size: 1rem; color: #3b82f6; }
        .sidebar-header span { font-size: 0.75rem; color: #94a3b8; }
        .sidebar-menu { padding: 10px 0; }
        .sidebar-menu a {
            display: flex; align-items: center; padding: 10px 16px; color: #94a3b8;
            text-decoration: none; font-size: 0.85rem; transition: all 0.2s;
            border-left: 3px solid transparent;
        }
        .sidebar-menu a:hover { background: #334155; color: #e2e8f0; }
        .sidebar-menu a.active { background: #334155; color: #3b82f6; border-left-color: #3b82f6; }
        .sidebar-menu .icon { width: 16px; margin-right: 10px; text-align: center; color: #64748b; font-size: 0.6rem; }
        .sidebar-divider { height: 1px; background: #334155; margin: 8px 16px; }

        /* Main layout */
        .main-content { flex: 1; margin-left: 220px; }
        .top-header {
            background: #fff; padding: 12px 25px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.08); position: sticky; top: 0; z-index: 100;
        }
        .top-header h1 { font-size: 1.2rem; color: #1e293b; margin: 0; }
        .user-info { display: flex; align-items: center; gap: 12px; font-size: 0.85rem; color: #64748b; }
        .user-info a { color: #3b82f6; text-decoration: none; }
        .page-content { padding: 25px; }

        /* Content cards */
        .content-card { background: #fff; border-radius: 8px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); margin-bottom: 20px; }
        .content-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 10px; }

        /* Admin table */
        .admin-table { width: 100%; border-collapse: collapse; }
        .admin-table th { background: #f8fafc; color: #475569; padding: 10px 12px; text-align: left; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        .admin-table td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; color: #334155; vertical-align: middle; }
        .admin-table tr:hover { background: #f8fafc; }
        .table-image { width: 45px; height: 45px; object-fit: cover; border-radius: 6px; }

        /* Stats */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 25px; }
        .stat-card { background: #fff; border-radius: 8px; padding: 20px; display: flex; align-items: center; gap: 15px; box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
        .stat-icon { width: 50px; height: 50px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; font-weight: 700; }
        .stat-icon.users { background: #dbeafe; color: #1d4ed8; }
        .stat-icon.users::after { content: "U"; }
        .stat-icon.products { background: #dcfce7; color: #15803d; }
        .stat-icon.products::after { content: "P"; }
        .stat-icon.orders { background: #fef3c7; color: #b45309; }
        .stat-icon.orders::after { content: "O"; }
        .stat-info h3 { color: #64748b; font-size: 0.8rem; font-weight: 500; margin: 0; }
        .stat-number { font-size: 1.5rem; font-weight: 700; color: #1e293b; }
        .stat-detail { font-size: 0.75rem; color: #94a3b8; }

        /* Small button variant (Bootstrap uses btn-sm) */
        .btn-small { padding: 5px 10px; font-size: 0.78rem; }

        /* Status badges */
        .status { padding: 3px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 500; }
        .status.active, .status-completed { background: #dcfce7; color: #166534; }
        .status.inactive, .status-cancelled { background: #fef2f2; color: #991b1b; }
        .status-pending { background: #fef3c7; color: #92400e; }
        .status-confirmed, .status-shipping { background: #dbeafe; color: #1e40af; }

        /* Forms */
        .form-container { max-width: 700px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .form-actions { display: flex; gap: 10px; margin-top: 20px; padding-top: 20px; border-top: 1px solid #e2e8f0; }
        .field-error { color: #dc3545; font-size: 0.78rem; margin-top: 3px; }

        /* Search */
        .search-form { display: flex; gap: 8px; align-items: center; }
        .search-form .form-control { max-width: 250px; }

        /* Actions column */
        .actions { white-space: nowrap; }
        .actions .btn { margin-right: 4px; }
        .role-select { padding: 4px 8px; border: 1px solid #e2e8f0; border-radius: 4px; font-size: 0.8rem; }

        /* No data */
        .no-data { text-align: center; padding: 40px; color: #64748b; }

        /* Pagination */
        .admin-pagination { display: flex; justify-content: space-between; align-items: center; margin-top: 16px; flex-wrap: wrap; gap: 10px; }
        .admin-pagination .page-info { color: #64748b; font-size: 0.85rem; }
        .admin-pagination .page-btns { display: flex; gap: 4px; flex-wrap: wrap; }
        .admin-pagination .pg { display: inline-flex; align-items: center; justify-content: center; min-width: 34px; height: 34px; padding: 0 8px; border-radius: 6px; font-size: 0.83rem; font-weight: 500; text-decoration: none; color: #475569; background: #f8fafc; border: 1px solid #e2e8f0; transition: all 0.15s; }
        .admin-pagination .pg:hover { background: #eff6ff; border-color: #93c5fd; color: #1d4ed8; }
        .admin-pagination .pg.active { background: #3b82f6; border-color: #3b82f6; color: #fff; pointer-events: none; }
        .admin-pagination .pg.disabled { opacity: 0.4; pointer-events: none; }
        .admin-pagination .pg-ellipsis { display: inline-flex; align-items: center; justify-content: center; min-width: 34px; height: 34px; color: #94a3b8; }

        /* Order detail */
        .order-info-section { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 15px; margin-bottom: 20px; }
        .info-card { background: #f8fafc; border-radius: 8px; padding: 18px; }
        .info-card h3 { font-size: 0.9rem; color: #1e293b; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #e2e8f0; }
        .info-row { display: flex; justify-content: space-between; padding: 5px 0; font-size: 0.85rem; }
        .info-row .label { color: #64748b; }
        .info-row .value { color: #1e293b; }
        .status-form .form-group { display: flex; gap: 8px; align-items: center; }
        .order-items-table { width: 100%; border-collapse: collapse; }
        .order-items-table th { background: #f8fafc; padding: 10px 12px; text-align: left; font-size: 0.8rem; color: #475569; border-bottom: 2px solid #e2e8f0; }
        .order-items-table td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; }
        .order-items-table .total-row td { font-weight: 600; border-top: 2px solid #e2e8f0; background: #f8fafc; }

        /* Alerts - map alert-error to Bootstrap danger */
        .alert-error { --bs-alert-color: #842029; --bs-alert-bg: #f8d7da; --bs-alert-border-color: #f5c2c7; }

        @media (max-width: 768px) {
            .sidebar { width: 60px; }
            .sidebar-header h2, .sidebar-header span, .sidebar-menu span { display: none; }
            .sidebar-menu a { justify-content: center; padding: 12px; }
            .sidebar-menu .icon { margin: 0; }
            .main-content { margin-left: 60px; }
            .form-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="admin-layout">
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2>Smart Mobile Shop</h2>
                <span>Admin Panel</span>
            </div>
            <nav class="sidebar-menu">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="${activePage == 'dashboard' ? 'active' : ''}">
                    <span class="icon">&#9642;</span><span>Dashboard</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/products" class="${activePage == 'products' ? 'active' : ''}">
                    <span class="icon">&#9642;</span><span>Products</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/brands" class="${activePage == 'brands' ? 'active' : ''}">
                    <span class="icon">&#9642;</span><span>Brands</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/categories" class="${activePage == 'categories' ? 'active' : ''}">
                    <span class="icon">&#9642;</span><span>Categories</span>
                </a>
                <div class="sidebar-divider"></div>
                <a href="${pageContext.request.contextPath}/admin/orders" class="${activePage == 'orders' ? 'active' : ''}">
                    <span class="icon">&#9642;</span><span>Orders</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users" class="${activePage == 'users' ? 'active' : ''}">
                    <span class="icon">&#9642;</span><span>Users</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/qa" class="${activePage == 'qa' ? 'active' : ''}">
                    <span class="icon">&#9642;</span><span>Q&amp;A Moderation</span>
                </a>
                <div class="sidebar-divider"></div>
                <a href="${pageContext.request.contextPath}/">
                    <span class="icon">&#9642;</span><span>View Store</span>
                </a>
                <a href="${pageContext.request.contextPath}/auth?action=logout">
                    <span class="icon">&#9642;</span><span>Logout</span>
                </a>
            </nav>
        </aside>

        <main class="main-content">
            <header class="top-header">
                <h1>${pageTitle}</h1>
                <div class="user-info">
                    <span>${sessionScope.LOGIN_USER.fullName}</span>
                    <a href="${pageContext.request.contextPath}/auth?action=logout">Logout</a>
                </div>
            </header>
            <div class="page-content">
