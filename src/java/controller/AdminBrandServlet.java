package controller;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Brand;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/brands")
public class AdminBrandServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private BrandDAO brandDAO;
    
    @Override
    public void init() throws ServletException {
        brandDAO = new BrandDAO();
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
                handleBrandList(request, response);
                break;
            case "form":
                handleBrandForm(request, response);
                break;
            case "edit":
                handleEditBrand(request, response);
                break;
            case "delete":
                handleDeleteBrand(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
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
                handleAddBrand(request, response);
                break;
            case "update":
                handleUpdateBrand(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
                break;
        }
    }
    
    private void handleBrandList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pageStr = request.getParameter("page");
        List<Brand> allBrands = brandDAO.getAllBrands();

        int total = allBrands.size();
        int currentPage = 1;
        try {
            if (pageStr != null && !pageStr.trim().isEmpty())
                currentPage = Math.max(1, Integer.parseInt(pageStr));
        } catch (NumberFormatException e) { /* ignore */ }

        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int from = (currentPage - 1) * PAGE_SIZE;
        int to = Math.min(from + PAGE_SIZE, total);
        List<Brand> brands = total > 0 ? allBrands.subList(from, to) : allBrands;

        request.setAttribute("brands", brands);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", total);
        request.getRequestDispatcher("/admin/brand-list.jsp").forward(request, response);
    }
    
    private void handleBrandForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
    }
    
    private void handleEditBrand(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String brandIdStr = request.getParameter("id");
        
        if (brandIdStr == null || brandIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
            return;
        }
        
        try {
            int brandId = Integer.parseInt(brandIdStr);
            Brand brand = brandDAO.getBrandById(brandId);
            
            if (brand == null) {
                response.sendRedirect(request.getContextPath() + "/admin/brands?action=list&error=Brand not found");
                return;
            }
            
            request.setAttribute("brand", brand);
            request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
        }
    }
    
    private void handleAddBrand(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String brandName = request.getParameter("brandName");
        String statusStr = request.getParameter("status");
        String normalizedBrandName = brandName == null ? null : brandName.trim();
        
        if (normalizedBrandName == null || normalizedBrandName.isEmpty()) {
            request.setAttribute("error", "Brand name is required");
            request.setAttribute("brandName", brandName);
            request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
            return;
        }

        if (normalizedBrandName.length() < 2 || normalizedBrandName.length() > 100) {
            request.setAttribute("error", "Brand name must be from 2 to 100 characters");
            request.setAttribute("brandName", brandName);
            request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
            return;
        }
        
        if (brandDAO.isBrandNameExists(normalizedBrandName)) {
            request.setAttribute("error", "Brand name already exists");
            request.setAttribute("brandName", brandName);
            request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
            return;
        }
        
        Brand brand = new Brand();
        brand.setBrandName(normalizedBrandName);
        brand.setStatus("1".equals(statusStr) || "true".equals(statusStr));
        
        if (brandDAO.addBrand(brand)) {
            response.sendRedirect(request.getContextPath() + "/admin/brands?action=list&message=Brand added successfully");
        } else {
            request.setAttribute("error", "Failed to add brand");
            request.setAttribute("brandName", brandName);
            request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
        }
    }
    
    private void handleUpdateBrand(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String brandIdStr = request.getParameter("brandId");
        String brandName = request.getParameter("brandName");
        String statusStr = request.getParameter("status");
        
        if (brandIdStr == null || brandIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
            return;
        }
        
        try {
            int brandId = Integer.parseInt(brandIdStr);
            String normalizedBrandName = brandName == null ? null : brandName.trim();
            
            if (normalizedBrandName == null || normalizedBrandName.isEmpty()) {
                Brand existingBrand = brandDAO.getBrandById(brandId);
                request.setAttribute("error", "Brand name is required");
                request.setAttribute("brand", existingBrand);
                request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
                return;
            }

            if (normalizedBrandName.length() < 2 || normalizedBrandName.length() > 100) {
                Brand existingBrand = brandDAO.getBrandById(brandId);
                request.setAttribute("error", "Brand name must be from 2 to 100 characters");
                request.setAttribute("brand", existingBrand);
                request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
                return;
            }
            
            if (brandDAO.isBrandNameExists(normalizedBrandName, brandId)) {
                Brand existingBrand = brandDAO.getBrandById(brandId);
                request.setAttribute("error", "Brand name already exists");
                request.setAttribute("brand", existingBrand);
                request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
                return;
            }
            
            Brand brand = new Brand();
            brand.setBrandId(brandId);
            brand.setBrandName(normalizedBrandName);
            brand.setStatus("1".equals(statusStr) || "true".equals(statusStr));
            
            if (brandDAO.updateBrand(brand)) {
                response.sendRedirect(request.getContextPath() + "/admin/brands?action=list&message=Brand updated successfully");
            } else {
                request.setAttribute("error", "Failed to update brand");
                request.setAttribute("brand", brand);
                request.getRequestDispatcher("/admin/brand-form.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
        }
    }
    
    private void handleDeleteBrand(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String brandIdStr = request.getParameter("id");
        
        if (brandIdStr == null || brandIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
            return;
        }
        
        try {
            int brandId = Integer.parseInt(brandIdStr);
            
            if (brandDAO.deleteBrand(brandId)) {
                response.sendRedirect(request.getContextPath() + "/admin/brands?action=list&message=Brand deleted successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/brands?action=list&error=Failed to delete brand");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/brands?action=list");
        }
    }
}