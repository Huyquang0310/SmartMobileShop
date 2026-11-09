package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.util.List;
import java.util.regex.Pattern;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^(03|05|07|08|09)\\d{8}$");
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "list":
                handleUserList(request, response);
                break;
            case "form":
                request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
                break;
            case "edit":
                handleEditUser(request, response);
                break;
            case "delete":
                handleDeleteUser(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String action = request.getParameter("action");
        
        switch (action == null ? "" : action) {
            case "insert":
                handleAddUser(request, response);
                break;
            case "update":
                handleUpdateUser(request, response);
                break;
            case "update-status":
                handleUpdateUserStatus(request, response);
                break;
            case "update-role":
                handleUpdateUserRole(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
                break;
        }
    }
    
    private void handleUserList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");
        List<User> allUsers;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            allUsers = userDAO.searchUsers(keyword.trim());
        } else {
            allUsers = userDAO.getAllUsers();
        }

        int total = allUsers.size();
        int currentPage = 1;
        try {
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                currentPage = Math.max(1, Integer.parseInt(pageStr));
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (totalPages < 1) {
            totalPages = 1;
        }
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int from = (currentPage - 1) * PAGE_SIZE;
        int to = Math.min(from + PAGE_SIZE, total);
        List<User> users = total > 0 ? allUsers.subList(from, to) : allUsers;
        
        request.setAttribute("users", users);
        request.setAttribute("keyword", keyword);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", total);
        request.getRequestDispatcher("/admin/user-list.jsp").forward(request, response);
    }

    private void handleEditUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdStr);
            User user = userDAO.getUserById(userId);
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=User not found");
                return;
            }

            request.setAttribute("user", user);
            request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
        }
    }

    private void handleAddUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = extractUserFromRequest(request, true, 0);
        if (user == null) {
            request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
            return;
        }

        if (userDAO.addUser(user)) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list&message=User%20created");
        } else {
            request.setAttribute("error", "Failed to add user");
            request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
        }
    }

    private void handleUpdateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdStr);
            User existingUser = userDAO.getUserById(userId);
            if (existingUser == null) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=User not found");
                return;
            }

            User user = extractUserFromRequest(request, false, userId);
            if (user == null) {
                existingUser.setFullName(request.getParameter("fullName"));
                existingUser.setUsername(request.getParameter("username"));
                existingUser.setEmail(request.getParameter("email"));
                existingUser.setPhone(request.getParameter("phone"));
                existingUser.setAddress(request.getParameter("address"));
                try {
                    existingUser.setRoleId(Integer.parseInt(request.getParameter("roleId")));
                } catch (Exception ignored) {
                    // Keep existing role if value is invalid
                }
                String statusStr = request.getParameter("status");
                existingUser.setStatus(!"0".equals(statusStr) && !"false".equalsIgnoreCase(statusStr));
                request.setAttribute("user", existingUser);
                request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession(false);
            User currentUser = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
            if (currentUser != null && currentUser.getUserId() == userId && user.getRoleId() != 1) {
                request.setAttribute("error", "You cannot remove your own admin role");
                user.setUserId(userId);
                request.setAttribute("user", user);
                request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
                return;
            }

            user.setUserId(userId);
            if (userDAO.updateUser(user)) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&message=User updated successfully");
            } else {
                request.setAttribute("error", "Failed to update user");
                user.setUserId(userId);
                request.setAttribute("user", user);
                request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
        }
    }

    private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdStr);

            HttpSession session = request.getSession(false);
            User currentUser = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
            if (currentUser != null && currentUser.getUserId() == userId) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Cannot delete your own account");
                return;
            }

            if (userDAO.hasOrders(userId)) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Cannot delete user with existing orders");
                return;
            }

            if (userDAO.deleteUser(userId)) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&message=User deleted successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Failed to delete user");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
        }
    }
    
    private void handleUpdateUserStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String userIdStr = request.getParameter("userId");
        String statusStr = request.getParameter("status");
        
        if (userIdStr == null || userIdStr.trim().isEmpty() || statusStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            boolean status = "1".equals(statusStr) || "true".equals(statusStr);
            
            // Prevent admin from modifying their own status
            if (currentUser.getUserId() == userId) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Cannot modify your own account status");
                return;
            }
            
            if (userDAO.updateUserStatus(userId, status)) {
                String message = status ? "User activated successfully" : "User deactivated successfully";
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&message=" + message);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Failed to update user status");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
        }
    }
    
    private void handleUpdateUserRole(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String userIdStr = request.getParameter("userId");
        String roleIdStr = request.getParameter("roleId");
        
        if (userIdStr == null || userIdStr.trim().isEmpty() || roleIdStr == null || roleIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            int roleId = Integer.parseInt(roleIdStr);

            if (roleId != 1 && roleId != 2) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Invalid role");
                return;
            }
            
            // Prevent admin from modifying their own role
            if (currentUser.getUserId() == userId) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Cannot modify your own account role");
                return;
            }
            
            if (userDAO.updateUserRole(userId, roleId)) {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&message=User role updated successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list&error=Failed to update user role");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
        }
    }

    private User extractUserFromRequest(HttpServletRequest request, boolean isCreate, int excludeUserId) {
        String fullName = trimParam(request.getParameter("fullName"));
        String username = trimParam(request.getParameter("username"));
        String email = trimParam(request.getParameter("email"));
        String password = request.getParameter("password");
        String phone = trimParam(request.getParameter("phone"));
        String address = trimParam(request.getParameter("address"));
        String roleIdStr = trimParam(request.getParameter("roleId"));
        String statusStr = trimParam(request.getParameter("status"));

        request.setAttribute("fullName", fullName);
        request.setAttribute("username", username);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("address", address);
        request.setAttribute("roleId", roleIdStr);
        request.setAttribute("status", statusStr);

        if (fullName == null || fullName.length() < 2 || fullName.length() > 100) {
            request.setAttribute("error", "Full name must be from 2 to 100 characters");
            return null;
        }

        if (username == null || username.length() < 3 || username.length() > 50) {
            request.setAttribute("error", "Username must be from 3 to 50 characters");
            return null;
        }

        if (email == null || email.length() > 100 || !EMAIL_PATTERN.matcher(email).matches()) {
            request.setAttribute("error", "Email format is invalid");
            return null;
        }

        if (isCreate && (password == null || password.trim().length() < 8 || password.trim().length() > 100)) {
            request.setAttribute("error", "Password must be from 6 to 100 characters");
            return null;
        }

        if (phone != null && !phone.isEmpty() && !PHONE_PATTERN.matcher(phone).matches()) {
            request.setAttribute("error", "Phone must be 10 digits and start with 03, 05, 07, 08, or 09");
            return null;
        }

        if (address != null && address.length() > 255) {
            request.setAttribute("error", "Address cannot exceed 255 characters");
            return null;
        }

        int roleId;
        try {
            roleId = Integer.parseInt(roleIdStr);
        } catch (Exception e) {
            request.setAttribute("error", "Role is required");
            return null;
        }

        if (roleId != 1 && roleId != 2) {
            request.setAttribute("error", "Role is invalid");
            return null;
        }

        if (isCreate) {
            if (userDAO.isUsernameExists(username)) {
                request.setAttribute("error", "Username already exists");
                return null;
            }
            if (userDAO.isEmailExists(email)) {
                request.setAttribute("error", "Email already exists");
                return null;
            }
        } else {
            if (userDAO.isUsernameExists(username, excludeUserId)) {
                request.setAttribute("error", "Username already exists");
                return null;
            }
            if (userDAO.isEmailExists(email, excludeUserId)) {
                request.setAttribute("error", "Email already exists");
                return null;
            }
        }

        boolean status = !"0".equals(statusStr) && !"false".equalsIgnoreCase(statusStr);

        User user = new User();
        user.setFullName(fullName);
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(password != null ? password.trim() : null);
        user.setPhone(phone);
        user.setAddress(address);
        user.setRoleId(roleId);
        user.setStatus(status);
        return user;
    }

    private String trimParam(String value) {
        return value == null ? null : value.trim();
    }
}