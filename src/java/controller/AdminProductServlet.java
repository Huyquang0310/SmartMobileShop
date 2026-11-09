package controller;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Brand;
import model.Category;
import model.Product;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/admin/products")
public class AdminProductServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private ProductDAO productDAO;
    private BrandDAO brandDAO;
    private CategoryDAO categoryDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        brandDAO = new BrandDAO();
        categoryDAO = new CategoryDAO();
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
                handleProductList(request, response);
                break;
            case "form":
                handleProductForm(request, response);
                break;
            case "edit":
                handleEditProduct(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
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

        switch (action == null ? "" : action) {
            case "insert":
                handleAddProduct(request, response);
                break;
            case "update":
                handleUpdateProduct(request, response);
                break;
            case "adjust-stock":
                handleAdjustStock(request, response);
                break;
            case "delete":
                handleDeleteProduct(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
                break;
        }
    }
    
    private void handleProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        Integer brandId = positiveInt(request.getParameter("brandId"));
        Integer categoryId = positiveInt(request.getParameter("categoryId"));
        String visibility = optional(request.getParameter("visibility"));
        String stockFilter = optional(request.getParameter("stock"));
        String sortBy = optional(request.getParameter("sortBy"));
        List<Product> allProducts = productDAO.searchAdminProducts(keyword, brandId, categoryId,
                visibility, stockFilter, sortBy);
        int total = allProducts.size();
        int currentPage = positiveInt(request.getParameter("page")) == null ? 1
                : positiveInt(request.getParameter("page"));
        int totalPages = Math.max(1, (int) Math.ceil((double) total / PAGE_SIZE));
        currentPage = Math.min(currentPage, totalPages);
        int from = (currentPage - 1) * PAGE_SIZE;
        int to = Math.min(from + PAGE_SIZE, total);
        request.setAttribute("products", total > 0 ? allProducts.subList(from, to) : allProducts);
        request.setAttribute("brands", brandDAO.getAllBrands());
        request.setAttribute("categories", categoryDAO.getAllCategories());
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("visibility", visibility);
        request.setAttribute("stockFilter", stockFilter);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", total);
        String baseUrl = request.getContextPath() + "/admin/products?keyword=" + encode(keyword)
            + "&brandId=" + (brandId == null ? "" : brandId)
            + "&categoryId=" + (categoryId == null ? "" : categoryId)
            + "&visibility=" + encode(visibility) + "&stock=" + encode(stockFilter)
            + "&sortBy=" + encode(sortBy);
        request.setAttribute("paginationBaseUrl", baseUrl);
        request.getRequestDispatcher("/admin/product-list.jsp").forward(request, response);
    }

    private Integer positiveInt(String value) {
        try {
            int n = Integer.parseInt(value);
            return n > 0 ? n : null;
        } catch (Exception e) {
            return null;
        }
    }

    private String optional(String value) {
        return value == null ? "" : value.trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private void handleAdjustStock(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer productId = positiveInt(request.getParameter("productId"));
        Integer amount = positiveInt(request.getParameter("amount"));
        String direction = request.getParameter("direction");
        if (productId == null || amount == null || amount > 1000000
                || !("add".equals(direction) || "remove".equals(direction))) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=Invalid stock adjustment");
            return;
        }
        int delta = "remove".equals(direction) ? -amount : amount;
        boolean updated = productDAO.adjustStock(productId, delta);
        response.sendRedirect(request.getContextPath() + "/admin/products?"
            + (updated ? "message=Stock updated" : "error=Unable to adjust stock; check available quantity"));
    }

    private void handleProductForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Brand> brands = brandDAO.getActiveBrands();
        List<Category> categories = categoryDAO.getActiveCategories();
        
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
    }
    
    private void handleEditProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("id");
        
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = productDAO.getProductById(productId);
            
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/products?action=list&error=Product not found");
                return;
            }
            
            List<Brand> brands = brandDAO.getAllBrands();
            List<Category> categories = categoryDAO.getAllCategories();
            
            request.setAttribute("product", product);
            request.setAttribute("brands", brands);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
        }
    }
    
    private void handleAddProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Product product = extractProductFromRequest(request);
        
        if (product == null) {
            List<Brand> brands = brandDAO.getActiveBrands();
            List<Category> categories = categoryDAO.getActiveCategories();
            request.setAttribute("brands", brands);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
            return;
        }
        
        if (productDAO.addProduct(product)) {
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list&message=Product added successfully");
        } else {
            request.setAttribute("error", "Failed to add product");
            List<Brand> brands = brandDAO.getActiveBrands();
            List<Category> categories = categoryDAO.getActiveCategories();
            request.setAttribute("brands", brands);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
        }
    }
    
    private void handleUpdateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productIdStr = request.getParameter("productId");
        
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = extractProductFromRequest(request, true);
            
            if (product == null) {
                Product existingProduct = productDAO.getProductById(productId);
                List<Brand> brands = brandDAO.getAllBrands();
                List<Category> categories = categoryDAO.getAllCategories();
                request.setAttribute("product", existingProduct);
                request.setAttribute("brands", brands);
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
                return;
            }
            
            product.setProductId(productId);
            
            if (productDAO.updateProduct(product)) {
                response.sendRedirect(request.getContextPath() + "/admin/products?action=list&message=Product updated successfully");
            } else {
                request.setAttribute("error", "Failed to update product");
                List<Brand> brands = brandDAO.getAllBrands();
                List<Category> categories = categoryDAO.getAllCategories();
                request.setAttribute("product", product);
                request.setAttribute("brands", brands);
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("/admin/product-form.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
        }
    }
    
    private void handleDeleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String productIdStr = request.getParameter("id");
        
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            if (productDAO.deleteProduct(productId)) {
                response.sendRedirect(request.getContextPath() + "/admin/products?action=list&message=Product deleted successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?action=list&error=Cannot delete product with order history; deactivate it instead");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
        }
    }
    
    private Product extractProductFromRequest(HttpServletRequest request) {
        return extractProductFromRequest(request, false);
    }

    private Product extractProductFromRequest(HttpServletRequest request, boolean editing) {
        String productName = request.getParameter("productName");
        String brandIdStr = request.getParameter("brandId");
        String categoryIdStr = request.getParameter("categoryId");
        String priceStr = request.getParameter("price");
        String quantityStr = editing ? "0" : request.getParameter("quantity");
        String description = request.getParameter("description");
        String imageUrl = request.getParameter("imageUrl");
        String ram = request.getParameter("ram");
        String rom = request.getParameter("rom");
        String screen = request.getParameter("screen");
        String battery = request.getParameter("battery");
        String statusStr = request.getParameter("status");
        
        // Validation
        if (productName == null || productName.trim().isEmpty() ||
            brandIdStr == null || brandIdStr.trim().isEmpty() ||
            categoryIdStr == null || categoryIdStr.trim().isEmpty() ||
            priceStr == null || priceStr.trim().isEmpty() ||
            quantityStr == null || quantityStr.trim().isEmpty()) {
            
            request.setAttribute("error", "Please fill in all required fields");
            setFormData(request, productName, brandIdStr, categoryIdStr, priceStr, quantityStr,
                       description, imageUrl, ram, rom, screen, battery, statusStr);
            return null;
        }
        
        try {
            int brandId = Integer.parseInt(brandIdStr);
            int categoryId = Integer.parseInt(categoryIdStr);
            BigDecimal price = new BigDecimal(priceStr);
            int quantity = Integer.parseInt(quantityStr);
            boolean status = "1".equals(statusStr) || "true".equals(statusStr);

            String normalizedName = productName.trim();
            if (normalizedName.length() < 2 || normalizedName.length() > 200) {
                request.setAttribute("error", "Product name must be from 2 to 200 characters");
                setFormData(request, productName, brandIdStr, categoryIdStr, priceStr, quantityStr,
                           description, imageUrl, ram, rom, screen, battery, statusStr);
                return null;
            }

            if (brandId <= 0 || categoryId <= 0) {
                request.setAttribute("error", "Brand and category are required");
                setFormData(request, productName, brandIdStr, categoryIdStr, priceStr, quantityStr,
                           description, imageUrl, ram, rom, screen, battery, statusStr);
                return null;
            }
            
            if (price.compareTo(BigDecimal.ZERO) <= 0 || quantity < 0) {
                request.setAttribute("error", "Price must be positive and quantity cannot be negative");
                setFormData(request, productName, brandIdStr, categoryIdStr, priceStr, quantityStr,
                           description, imageUrl, ram, rom, screen, battery, statusStr);
                return null;
            }

            if (description != null && description.length() > 2000) {
                request.setAttribute("error", "Description is too long (max 2000 characters)");
                setFormData(request, productName, brandIdStr, categoryIdStr, priceStr, quantityStr,
                           description, imageUrl, ram, rom, screen, battery, statusStr);
                return null;
            }
            
            Product product = new Product();
            product.setProductName(normalizedName);
            product.setBrandId(brandId);
            product.setCategoryId(categoryId);
            product.setPrice(price);
            product.setQuantity(quantity);
            product.setDescription(description != null ? description.trim() : "");
            product.setImageUrl(imageUrl != null ? imageUrl.trim() : "");
            product.setRam(ram != null ? ram.trim() : "");
            product.setRom(rom != null ? rom.trim() : "");
            product.setScreen(screen != null ? screen.trim() : "");
            product.setBattery(battery != null ? battery.trim() : "");
            product.setStatus(status);
            
            return product;
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid number format");
            setFormData(request, productName, brandIdStr, categoryIdStr, priceStr, quantityStr,
                       description, imageUrl, ram, rom, screen, battery, statusStr);
            return null;
        }
    }
    
    private void setFormData(HttpServletRequest request, String productName, String brandId,
                           String categoryId, String price, String quantity, String description,
                           String imageUrl, String ram, String rom, String screen,
                           String battery, String status) {
        request.setAttribute("productName", productName);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("price", price);
        request.setAttribute("quantity", quantity);
        request.setAttribute("description", description);
        request.setAttribute("imageUrl", imageUrl);
        request.setAttribute("ram", ram);
        request.setAttribute("rom", rom);
        request.setAttribute("screen", screen);
        request.setAttribute("battery", battery);
        request.setAttribute("status", status);
    }
}