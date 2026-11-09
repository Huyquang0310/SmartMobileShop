package controller;

import dao.OrderDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;
import utils.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import jakarta.persistence.EntityTransaction;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.regex.Pattern;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^(03|05|07|08|09)\\d{8}$");
    
    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "history";
        }

        switch (action) {
            case "checkout":
                handleCheckoutPage(request, response);
                break;
            case "history":
                handleOrderHistory(request, response);
                break;
            case "detail":
                handleOrderDetail(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/order?action=history");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "place":
                handlePlaceOrder(request, response);
                break;
            case "cancel":
                handleCancelOrder(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/order?action=history");
                break;
        }
    }
    
    private void handleCheckoutPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view&error=Your cart is empty");
            return;
        }

        for (CartItem item : cart.getItems()) {
            Product product = productDAO.getVisibleProductById(item.getProduct().getProductId());
            if (product == null || !product.isStatus() || product.getQuantity() < item.getQuantity()) {
                response.sendRedirect(request.getContextPath() + "/cart?action=view&error=Cart contains unavailable products");
                return;
            }
            item.setProduct(product);
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }
    
    private void handlePlaceOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("LOGIN_USER");
        Cart cart = (Cart) session.getAttribute("cart");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view&error=Your cart is empty");
            return;
        }
        
        String receiverName = request.getParameter("receiverName");
        String receiverPhone = request.getParameter("receiverPhone");
        String receiverAddress = request.getParameter("receiverAddress");
        String note = request.getParameter("note");
        
        // Validation
        if (receiverName == null || receiverName.trim().isEmpty() ||
            receiverPhone == null || receiverPhone.trim().isEmpty() ||
            receiverAddress == null || receiverAddress.trim().isEmpty()) {
            
            request.setAttribute("error", "Please fill in all required fields");
            request.setAttribute("receiverName", receiverName);
            request.setAttribute("receiverPhone", receiverPhone);
            request.setAttribute("receiverAddress", receiverAddress);
            request.setAttribute("note", note);
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            return;
        }

        String normalizedReceiverPhone = receiverPhone.trim();
        if (!PHONE_PATTERN.matcher(normalizedReceiverPhone).matches()) {
            request.setAttribute("error", "Phone must be 10 digits and start with 03, 05, 07, 08, or 09.");
            request.setAttribute("receiverName", receiverName);
            request.setAttribute("receiverPhone", receiverPhone);
            request.setAttribute("receiverAddress", receiverAddress);
            request.setAttribute("note", note);
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            return;
        }
        
        // Validate stock availability for all items before creating order
        for (CartItem item : cart.getItems()) {
            Product currentProduct = productDAO.getVisibleProductById(item.getProduct().getProductId());
            if (currentProduct == null || !currentProduct.isStatus()) {
                request.setAttribute("error", "Product '" + item.getProduct().getProductName() + "' is no longer available");
                request.setAttribute("receiverName", receiverName);
                request.setAttribute("receiverPhone", receiverPhone);
                request.setAttribute("receiverAddress", receiverAddress);
                request.setAttribute("note", note);
                request.getRequestDispatcher("/checkout.jsp").forward(request, response);
                return;
            }
            if (currentProduct.getQuantity() < item.getQuantity()) {
                request.setAttribute("error", "Insufficient stock for '" + item.getProduct().getProductName() + "'. Available: " + currentProduct.getQuantity());
                request.setAttribute("receiverName", receiverName);
                request.setAttribute("receiverPhone", receiverPhone);
                request.setAttribute("receiverAddress", receiverAddress);
                request.setAttribute("note", note);
                request.getRequestDispatcher("/checkout.jsp").forward(request, response);
                return;
            }
        }
        
        // Create order within transaction
        Order order = new Order();
        order.setUserId(user.getUserId());
        order.setReceiverName(receiverName.trim());
        order.setReceiverPhone(normalizedReceiverPhone);
        order.setReceiverAddress(receiverAddress.trim());
        order.setNote(note != null ? note.trim() : "");
        order.setTotalAmount(BigDecimal.ZERO);
        order.setStatus("Pending");
        
        try (EntityManager em = JPAUtil.getEntityManager()) {
            EntityTransaction transaction = em.getTransaction();
            try {
                transaction.begin();

                BigDecimal total = BigDecimal.ZERO;
                Map<Integer, Product> lockedProducts = new HashMap<>();
                for (CartItem item : cart.getItems()) {
                    int productId = item.getProduct().getProductId();
                    Product product = em.find(Product.class, productId, LockModeType.PESSIMISTIC_WRITE);
                    if (!productDAO.isAvailableForSale(em, product) || item.getQuantity() < 1
                            || product.getQuantity() < item.getQuantity()
                            || !product.getPrice().equals(item.getProduct().getPrice())) {
                        throw new IllegalStateException("A product is unavailable or has insufficient stock");
                    }
                    lockedProducts.put(productId, product);
                    total = total.add(product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                }
                order.setTotalAmount(total);
                int newOrderId = orderDAO.createOrder(order, em);
                if (newOrderId <= 0) {
                    throw new IllegalStateException("Failed to create order");
                }

                for (CartItem item : cart.getItems()) {
                    Product product = lockedProducts.get(item.getProduct().getProductId());
                    OrderDetail orderDetail = new OrderDetail();
                    orderDetail.setOrderId(newOrderId);
                    orderDetail.setProductId(product.getProductId());
                    orderDetail.setQuantity(item.getQuantity());
                    orderDetail.setUnitPrice(product.getPrice());
                    orderDetail.setLineTotal(product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                    if (!orderDAO.createOrderDetail(orderDetail, em)) {
                        throw new IllegalStateException("Failed to create order detail");
                    }
                    product.setQuantity(product.getQuantity() - item.getQuantity());
                }

                transaction.commit();
                cart.clear();
                response.sendRedirect(request.getContextPath() + "/order?action=history&message=Order placed successfully");
            } catch (RuntimeException ex) {
                if (transaction.isActive()) {
                    transaction.rollback();
                }
                throw ex;
            }
        } catch (RuntimeException e) {
            System.err.println("Order creation failed: " + e.getMessage());
            request.setAttribute("error", "Failed to create order. Please try again.");
            request.setAttribute("receiverName", receiverName);
            request.setAttribute("receiverPhone", receiverPhone);
            request.setAttribute("receiverAddress", receiverAddress);
            request.setAttribute("note", note);
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
        }
    }
    
    private void handleOrderHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        
        List<Order> orders = orderDAO.getOrdersByUserId(user.getUserId());
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/order-history.jsp").forward(request, response);
    }
    
    private void handleOrderDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String orderIdStr = request.getParameter("id");
        
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/order?action=history");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdStr);
            
            Order order = orderDAO.getOrderById(orderId);
            
            if (order == null || order.getUserId() != user.getUserId()) {
                response.sendRedirect(request.getContextPath() + "/order?action=history&error=Order not found");
                return;
            }
            
            List<OrderDetail> orderDetails = orderDAO.getOrderDetailsByOrderId(orderId);
            order.setOrderDetails(orderDetails);
            
            request.setAttribute("order", order);
            request.getRequestDispatcher("/order-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/order?action=history");
        }
    }
    
    private void handleCancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/order?action=history");
            return;
        }
       
        try {
            int orderId = Integer.parseInt(orderIdStr);
            
            if (orderDAO.cancelOrder(orderId, user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/order?action=history&message=Order cancelled successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/order?action=history&error=Cannot cancel this order");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/order?action=history");
        }
    }
}