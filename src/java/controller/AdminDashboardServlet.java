package controller;

import dao.OrderDAO;
import dao.ReportDAO;
import dao.ProductDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.Product;
import model.User;

import java.io.IOException;
import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    
    private UserDAO userDAO;
    private ProductDAO productDAO;
    private OrderDAO orderDAO;
    private ReportDAO reportDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        productDAO = new ProductDAO();
        orderDAO = new OrderDAO();
        reportDAO = new ReportDAO();
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

        List<User> users = userDAO.getAllUsers();
        List<Product> products = productDAO.getAllProducts();
        List<Order> orders = orderDAO.getAllOrders();
        ReportDAO.Summary report = reportDAO.calculate();
        long physicalStockUnits = 0;
        long sellableStockUnits = 0;
        long outOfStockProducts = 0;
        long lowStockProducts = 0;
        long hiddenProducts = 0;
        BigDecimal inventoryValue = BigDecimal.ZERO;
        List<Product> stockWarnings = new ArrayList<>();
        for (Product product : products) {
            physicalStockUnits += product.getQuantity();
            inventoryValue = inventoryValue.add(product.getPrice().multiply(BigDecimal.valueOf(product.getQuantity())));
            if (product.isVisible()) {
                sellableStockUnits += product.getQuantity();
                if (product.getQuantity() == 0) outOfStockProducts++;
                else if (product.getQuantity() <= 5) lowStockProducts++;
                if (product.getQuantity() <= 5) stockWarnings.add(product);
            } else hiddenProducts++;
        }
        stockWarnings.sort(Comparator.comparingInt(Product::getQuantity));
        if (stockWarnings.size() > 8) stockWarnings = stockWarnings.subList(0, 8);
        long pending = 0, confirmed = 0, shipping = 0, completed = 0, cancelled = 0;
        Map<YearMonth, BigDecimal> sales = new LinkedHashMap<>();
        YearMonth currentMonth = YearMonth.now();
        for (int offset = 5; offset >= 0; offset--) sales.put(currentMonth.minusMonths(offset), BigDecimal.ZERO);
        for (Order order : orders) {
            switch (order.getStatus()) {
                case "Pending" -> pending++;
                case "Confirmed" -> confirmed++;
                case "Shipping" -> shipping++;
                case "Completed" -> {
                    completed++;
                    if (order.getOrderDate() != null) {
                        YearMonth month = YearMonth.from(order.getOrderDate().toLocalDateTime());
                        if (sales.containsKey(month)) {
                            sales.put(month, sales.get(month).add(order.getTotalAmount()));
                        }
                    }
                }
                case "Cancelled" -> cancelled++;
                default -> { }
            }
        }
        BigDecimal averageOrderValue = completed == 0 ? BigDecimal.ZERO
            : report.getTotalRevenue().divide(BigDecimal.valueOf(completed), 2, RoundingMode.HALF_UP);
        request.setAttribute("report", report);
        request.setAttribute("totalUsers", users.size());
        request.setAttribute("totalProducts", products.size());
        request.setAttribute("activeProducts", products.size() - hiddenProducts);
        request.setAttribute("hiddenProducts", hiddenProducts);
        request.setAttribute("physicalStockUnits", physicalStockUnits);
        request.setAttribute("sellableStockUnits", sellableStockUnits);
        request.setAttribute("inventoryValue", inventoryValue);
        request.setAttribute("outOfStockProducts", outOfStockProducts);
        request.setAttribute("lowStockProducts", lowStockProducts);
        request.setAttribute("stockWarnings", stockWarnings);
        request.setAttribute("totalOrders", orders.size());
        request.setAttribute("pendingOrders", pending);
        request.setAttribute("confirmedOrders", confirmed);
        request.setAttribute("shippingOrders", shipping);
        request.setAttribute("completedOrders", completed);
        request.setAttribute("cancelledOrders", cancelled);
        request.setAttribute("averageOrderValue", averageOrderValue);
        request.setAttribute("monthlySales", sales);
        request.setAttribute("recentOrders", orders.subList(0, Math.min(5, orders.size())));

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}