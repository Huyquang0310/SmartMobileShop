package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/categories")
public class AdminCategoryServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private CategoryDAO categoryDAO;
    
    @Override
    public void init() throws ServletException {
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
                handleCategoryList(request, response);
                break;
            case "form":
                handleCategoryForm(request, response);
                break;
            case "edit":
                handleEditCategory(request, response);
                break;
            case "delete":
                handleDeleteCategory(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
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
                handleAddCategory(request, response);
                break;
            case "update":
                handleUpdateCategory(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
                break;
        }
    }
    
    private void handleCategoryList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pageStr = request.getParameter("page");
        List<Category> allCategories = categoryDAO.getAllCategories();

        int total = allCategories.size();
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
        List<Category> categories = total > 0 ? allCategories.subList(from, to) : allCategories;

        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", total);
        request.getRequestDispatcher("/admin/category-list.jsp").forward(request, response);
    }
    
    private void handleCategoryForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
    }
    
    private void handleEditCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String categoryIdStr = request.getParameter("id");
        
        if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            Category category = categoryDAO.getCategoryById(categoryId);
            
            if (category == null) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=list&error=Category not found");
                return;
            }
            
            request.setAttribute("category", category);
            request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
        }
    }
    
    private void handleAddCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String categoryName = request.getParameter("categoryName");
        String statusStr = request.getParameter("status");
        String normalizedCategoryName = categoryName == null ? null : categoryName.trim();
        
        if (normalizedCategoryName == null || normalizedCategoryName.isEmpty()) {
            request.setAttribute("error", "Category name is required");
            request.setAttribute("categoryName", categoryName);
            request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
            return;
        }

        if (normalizedCategoryName.length() < 2 || normalizedCategoryName.length() > 100) {
            request.setAttribute("error", "Category name must be from 2 to 100 characters");
            request.setAttribute("categoryName", categoryName);
            request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
            return;
        }
        
        if (categoryDAO.isCategoryNameExists(normalizedCategoryName)) {
            request.setAttribute("error", "Category name already exists");
            request.setAttribute("categoryName", categoryName);
            request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
            return;
        }
        
        Category category = new Category();
        category.setCategoryName(normalizedCategoryName);
        category.setStatus("1".equals(statusStr) || "true".equals(statusStr));
        
        if (categoryDAO.addCategory(category)) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list&message=Category added successfully");
        } else {
            request.setAttribute("error", "Failed to add category");
            request.setAttribute("categoryName", categoryName);
            request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
        }
    }
    
    private void handleUpdateCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String categoryIdStr = request.getParameter("categoryId");
        String categoryName = request.getParameter("categoryName");
        String statusStr = request.getParameter("status");
        
        if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            String normalizedCategoryName = categoryName == null ? null : categoryName.trim();
            
            if (normalizedCategoryName == null || normalizedCategoryName.isEmpty()) {
                Category existingCategory = categoryDAO.getCategoryById(categoryId);
                request.setAttribute("error", "Category name is required");
                request.setAttribute("category", existingCategory);
                request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
                return;
            }

            if (normalizedCategoryName.length() < 2 || normalizedCategoryName.length() > 100) {
                Category existingCategory = categoryDAO.getCategoryById(categoryId);
                request.setAttribute("error", "Category name must be from 2 to 100 characters");
                request.setAttribute("category", existingCategory);
                request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
                return;
            }
            
            if (categoryDAO.isCategoryNameExists(normalizedCategoryName, categoryId)) {
                Category existingCategory = categoryDAO.getCategoryById(categoryId);
                request.setAttribute("error", "Category name already exists");
                request.setAttribute("category", existingCategory);
                request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
                return;
            }
            
            Category category = new Category();
            category.setCategoryId(categoryId);
            category.setCategoryName(normalizedCategoryName);
            category.setStatus("1".equals(statusStr) || "true".equals(statusStr));
            
            if (categoryDAO.updateCategory(category)) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=list&message=Category updated successfully");
            } else {
                request.setAttribute("error", "Failed to update category");
                request.setAttribute("category", category);
                request.getRequestDispatcher("/admin/category-form.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
        }
    }
    
    private void handleDeleteCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String categoryIdStr = request.getParameter("id");
        
        if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            
            if (categoryDAO.deleteCategory(categoryId)) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=list&message=Category deleted successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories?action=list&error=Failed to delete category");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?action=list");
        }
    }
}