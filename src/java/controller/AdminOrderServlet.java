package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.OrderDetail;
import model.User;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {
    
    private OrderDAO orderDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "list":
                handleOrderList(request, response);
                break;
            case "detail":
                handleOrderDetail(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=list");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");

        if ("update-status".equals(action)) {
            handleUpdateOrderStatus(request, response);
        } else if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("orderId"));
                boolean success = orderDAO.deleteCancelledOrder(id);
                response.sendRedirect(request.getContextPath() + "/admin/orders?" +
                    (success ? "message=Cancelled order deleted" : "error=Only cancelled orders can be deleted"));
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?error=Invalid order");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=list");
        }
    }
    
    private void handleOrderList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Order> orders = orderDAO.getAllOrders();
        String status = request.getParameter("status");
        if (status != null && ("Pending".equals(status) || "Confirmed".equals(status)
                || "Shipping".equals(status) || "Completed".equals(status) || "Cancelled".equals(status))) {
            orders = orders.stream().filter(order -> status.equals(order.getStatus())).toList();
            request.setAttribute("selectedStatus", status);
        }
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/admin/order-list.jsp").forward(request, response);
    }
    
    private void handleOrderDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String orderIdStr = request.getParameter("id");
        
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=list");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=list&error=Order not found");
                return;
            }
            
            List<OrderDetail> orderDetails = orderDAO.getOrderDetailsByOrderId(orderId);
            order.setOrderDetails(orderDetails);

            List<String> allowedNextStatuses = getAllowedNextStatuses(order.getStatus());
            request.setAttribute("allowedNextStatuses", allowedNextStatuses);
            request.setAttribute("canUpdateStatus", !allowedNextStatuses.isEmpty());
            
            request.setAttribute("order", order);
            request.getRequestDispatcher("/admin/order-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=list");
        }
    }
    
    private void handleUpdateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String orderIdStr = request.getParameter("orderId");
        String newStatus = request.getParameter("status");
        
        if (orderIdStr == null || orderIdStr.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=list");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdStr);

            Order existingOrder = orderDAO.getOrderById(orderId);
            if (existingOrder == null) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=list&error=Order not found");
                return;
            }

            String trimmedNewStatus = newStatus.trim();

            if (!isAllowedStatus(trimmedNewStatus)) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId + "&error=Invalid status");
                return;
            }

            if (!isValidStatusTransition(existingOrder.getStatus(), trimmedNewStatus)) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId + "&error=Invalid status transition");
                return;
            }
            
            // Update status
            if (orderDAO.updateOrderStatus(orderId, trimmedNewStatus)) {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId + 
                    "&message=Order status updated successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&id=" + orderId + 
                    "&error=Failed to update order status");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=list");
        }
    }

    private boolean isAllowedStatus(String status) {
        return "Pending".equals(status)
                || "Confirmed".equals(status)
                || "Shipping".equals(status)
                || "Completed".equals(status)
                || "Cancelled".equals(status);
    }

    private boolean isValidStatusTransition(String currentStatus, String newStatus) {
        if (currentStatus == null || newStatus == null) {
            return false;
        }

        if (currentStatus.equals(newStatus)) {
            return true;
        }

        List<String> allowedNext = getAllowedNextStatuses(currentStatus);
        return allowedNext.contains(newStatus);
    }

    private List<String> getAllowedNextStatuses(String currentStatus) {
        if ("Pending".equals(currentStatus)) {
            return Arrays.asList("Confirmed", "Cancelled");
        }
        if ("Confirmed".equals(currentStatus)) {
            return Arrays.asList("Shipping", "Cancelled");
        }
        if ("Shipping".equals(currentStatus)) {
            return Arrays.asList("Completed");
        }
        return new ArrayList<>();
    }
}