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
import java.util.regex.Pattern;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^(03|05|07|08|09)\\d{8}$");
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "login";
        }

        switch (action) {
            case "login":
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                break;
            case "register":
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                break;
            case "logout":
                handleLogout(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/auth?action=login");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "login":
                handleLogin(request, response);
                break;
            case "register":
                handleRegister(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/auth?action=login");
                break;
        }
    }
    
    //login
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String usernameOrEmail = request.getParameter("usernameOrEmail");
        String password = request.getParameter("password");
        
        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Please fill in all fields");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        User user = userDAO.login(usernameOrEmail.trim(), password);
        
        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("LOGIN_USER", user);
            
            String redirectUrl = request.getParameter("redirect");
            if (redirectUrl != null && redirectUrl.startsWith(request.getContextPath() + "/")
                    && !redirectUrl.contains("//") && !redirectUrl.contains("\\")) {
                response.sendRedirect(redirectUrl);
            } else if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/");
            }
        } else {
            request.setAttribute("error", "Invalid username/email or password");
            request.setAttribute("usernameOrEmail", usernameOrEmail);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
    
    //register
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        
        // Validation
        if (fullName == null || fullName.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            
            request.setAttribute("error", "Please fill in all required fields");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        // Email format validation
        if (!isValidEmail(email.trim())) {
            request.setAttribute("error", "Invalid email format");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        String normalizedPhone = phone != null ? phone.trim() : "";
        if (!normalizedPhone.isEmpty() && !isValidPhone(normalizedPhone)) {
            request.setAttribute("error", "Phone must be 10 digits and start with 03, 05, 07, 08, or 09");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        // Password strength validation
        if (password.length() < 8) {
            request.setAttribute("error", "Password must be at least 8 characters long");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        if (userDAO.isUsernameExists(username.trim())) {
            request.setAttribute("error", "Username already exists");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        if (userDAO.isEmailExists(email.trim())) {
            request.setAttribute("error", "Email already exists");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        User user = new User();
        user.setFullName(fullName.trim());
        user.setUsername(username.trim());
        user.setEmail(email.trim());
        user.setPassword(password);
        user.setPhone(normalizedPhone);
        user.setAddress(address != null ? address.trim() : "");
        user.setRoleId(2); // Customer role
        user.setStatus(true);
        
        if (userDAO.register(user)) {
            request.getRequestDispatcher("/registration-success.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            setFormData(request, fullName, username, email, phone, address);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
    
    /**
     * Validate email format
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.isEmpty()) {
            return false;
        }
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return email.matches(emailRegex);
    }

    private boolean isValidPhone(String phone) {
        return PHONE_PATTERN.matcher(phone).matches();
    }
    
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/");
    }
    
    private void setFormData(HttpServletRequest request, String fullName, String username,
                           String email, String phone, String address) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("username", username);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("address", address);
    }
}