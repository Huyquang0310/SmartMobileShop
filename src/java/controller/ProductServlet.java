package controller;

import dao.ProductDAO;
import dao.QaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import model.User;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/product-details")
public class ProductServlet extends HttpServlet {

    private ProductDAO productDAO;
    private QaDAO qaDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        qaDAO = new QaDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdStr = request.getParameter("id");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = productDAO.getVisibleProductById(productId);

            if (product == null || !product.isStatus()) {
                request.setAttribute("error", "Product not found");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }

            // Get related products (same brand or category, limit 4)
            List<Product> relatedProducts = productDAO.getRelatedProducts(
                productId, product.getBrandId(), product.getCategoryId(), 4
            );

            request.setAttribute("product", product);
            request.setAttribute("relatedProducts", relatedProducts);
            HttpSession session = request.getSession(false);
            User viewer = session == null ? null : (User) session.getAttribute("LOGIN_USER");
            request.setAttribute("questions", qaDAO.getVisibleForProduct(
                    productId, viewer == null ? 0 : viewer.getUserId(), viewer != null && viewer.isAdmin()));
            request.getRequestDispatcher("/product-details.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
        }
    }
}