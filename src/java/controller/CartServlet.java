package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.CartItem;
import model.Product;
import model.User;

import java.io.IOException;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty() || "view".equals(action)) {
            HttpSession session = request.getSession(false);
            Cart cart = session == null ? null : (Cart) session.getAttribute("cart");
            if (cart != null && !cart.isEmpty()) {
                java.util.List<Integer> removeIds = new java.util.ArrayList<>();
                for (CartItem item : cart.getItems()) {
                    int productId = item.getProduct().getProductId();
                    Product current = productDAO.getVisibleProductById(productId);
                    if (current == null) removeIds.add(productId);
                    else item.setProduct(current);
                }
                for (Integer productId : removeIds) cart.removeItem(productId);
                if (!removeIds.isEmpty()) request.setAttribute("cartNotice", "Unavailable products were removed from your cart.");
            }
            request.getRequestDispatcher("/cart.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "add":
                handleAddToCart(request, response, false);
                break;
            case "buy-now":
                handleAddToCart(request, response, true);
                break;
            case "update":
                handleUpdateCart(request, response);
                break;
            case "remove":
                handleRemoveFromCart(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/cart?action=view");
                break;
        }
    }

    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response, boolean buyNow)
            throws IOException {

        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            String productId = request.getParameter("productId");
            response.sendRedirect(request.getContextPath() + "/auth?action=login&redirect=" +
                request.getContextPath() + "/product-details?id=" + productId);
            return;
        }

        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        if (productIdStr == null || quantityStr == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            int quantity = Integer.parseInt(quantityStr);

            if (quantity <= 0) {
                response.sendRedirect(request.getContextPath() + "/product-details?id=" + productId + "&error=Invalid quantity");
                return;
            }

            Product product = productDAO.getVisibleProductById(productId);
            if (product == null || !product.isStatus()) {
                response.sendRedirect(request.getContextPath() + "/");
                return;
            }

            Cart cart = (Cart) session.getAttribute("cart");
            if (cart == null) {
                cart = new Cart();
                session.setAttribute("cart", cart);
            }

            // Check if adding this quantity would exceed stock
            if (!cart.addItem(product, quantity)) {
                int currentInCart = 0;
                for (CartItem item : cart.getItems()) {
                    if (item.getProduct().getProductId() == productId) {
                        currentInCart = item.getQuantity();
                        break;
                    }
                }
                int available = product.getQuantity() - currentInCart;
                response.sendRedirect(request.getContextPath() + "/product-details?id=" + productId +
                    "&error=Cannot add more than available stock. You already have " + currentInCart +
                    " in cart. Available: " + available);
                return;
            }

            // If buy now, redirect to checkout; otherwise redirect to cart
            if (buyNow) {
                response.sendRedirect(request.getContextPath() + "/order?action=checkout");
            } else {
                response.sendRedirect(request.getContextPath() + "/cart?action=view&message=Product added to cart");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
        }
    }
    
    private void handleUpdateCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");
        
        if (productIdStr == null || quantityStr == null) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            int quantity = Integer.parseInt(quantityStr);
            
            HttpSession session = request.getSession();
            Cart cart = (Cart) session.getAttribute("cart");
            if (cart != null) {
                if (quantity <= 0) {
                    cart.removeItem(productId);
                } else {
                    // Check stock availability
                    Product product = productDAO.getVisibleProductById(productId);
                    if (product != null && product.isStatus() && quantity <= product.getQuantity()) {
                        cart.updateItem(productId, quantity);
                        for (CartItem item : cart.getItems()) {
                            if (item.getProduct().getProductId() == productId) item.setProduct(product);
                        }
                    } else {
                        response.sendRedirect(request.getContextPath() + "/cart?action=view&error=Not enough stock");
                        return;
                    }
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
        }
    }
    
    private void handleRemoveFromCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String productIdStr = request.getParameter("productId");
        
        if (productIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            HttpSession session = request.getSession();
            Cart cart = (Cart) session.getAttribute("cart");
            if (cart != null) {
                cart.removeItem(productId);
            }
            
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
        }
    }
}