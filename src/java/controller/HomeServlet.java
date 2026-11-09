package controller;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Brand;
import model.Category;
import model.Product;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;

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

        String keyword    = request.getParameter("keyword");
        String brandIdStr = request.getParameter("brandId");
        String categoryIdStr = request.getParameter("categoryId");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String sortBy     = request.getParameter("sortBy");
        String pageStr    = request.getParameter("page");

        Integer brandId   = null;
        Integer categoryId = null;
        BigDecimal minPrice = null;
        BigDecimal maxPrice = null;
        int currentPage   = 1;

        try {
            if (brandIdStr != null && !brandIdStr.trim().isEmpty())
                brandId = Integer.parseInt(brandIdStr);
            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty())
                categoryId = Integer.parseInt(categoryIdStr);
            if (minPriceStr != null && !minPriceStr.trim().isEmpty())
                minPrice = new BigDecimal(minPriceStr);
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty())
                maxPrice = new BigDecimal(maxPriceStr);
            if (pageStr != null && !pageStr.trim().isEmpty())
                currentPage = Math.max(1, Integer.parseInt(pageStr));
        } catch (NumberFormatException e) {
            // ignore invalid values
        }

        int totalProducts = productDAO.countProducts(keyword, brandId, categoryId, minPrice, maxPrice);
        int totalPages = (int) Math.ceil((double) totalProducts / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int offset = (currentPage - 1) * PAGE_SIZE;
        List<Product> products = productDAO.searchProductsWithPaging(
                keyword, brandId, categoryId, minPrice, maxPrice, sortBy, offset, PAGE_SIZE);

        List<Brand> brands = brandDAO.getActiveBrands();

        request.setAttribute("products", products);
        request.setAttribute("brands", brands);
        request.setAttribute("categories", categoryDAO.getActiveCategories());
        boolean showRecommendations = currentPage == 1
                && (keyword == null || keyword.isBlank())
                && brandId == null && categoryId == null
                && (minPriceStr == null || minPriceStr.isBlank())
                && (maxPriceStr == null || maxPriceStr.isBlank())
                && (sortBy == null || sortBy.isBlank());
        request.setAttribute("showRecommendations", showRecommendations);
        boolean hasActiveFilters = (keyword != null && !keyword.isBlank())
                || brandId != null || categoryId != null
                || (minPriceStr != null && !minPriceStr.isBlank())
                || (maxPriceStr != null && !maxPriceStr.isBlank())
                || (sortBy != null && !sortBy.isBlank());
        request.setAttribute("hasActiveFilters", hasActiveFilters);
        if (showRecommendations) {
            request.setAttribute("newArrivals", productDAO.getNewArrivals(4));
            request.setAttribute("featuredProducts", productDAO.getFeaturedProducts(4));
            request.setAttribute("bestSellers", productDAO.getBestSellers(4));
        }
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("minPrice", minPriceStr);
        request.setAttribute("maxPrice", maxPriceStr);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
