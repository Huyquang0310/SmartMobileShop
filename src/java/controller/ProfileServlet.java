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

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

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
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String fullName = request.getParameter("fullName");
        String email    = request.getParameter("email");
        String phone    = request.getParameter("phone");
        String address  = request.getParameter("address");

        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Full name and email are required.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        String normalizedPhone = phone != null ? phone.trim() : "";
        if (!normalizedPhone.isEmpty() && !PHONE_PATTERN.matcher(normalizedPhone).matches()) {
            request.setAttribute("error", "Phone must be 10 digits and start with 03, 05, 07, 08, or 09.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        if (userDAO.updateProfile(user.getUserId(), fullName.trim(), email.trim(),
                normalizedPhone,
                address != null ? address.trim() : "")) {
            // Update session with new data
            user.setFullName(fullName.trim());
            user.setEmail(email.trim());
            user.setPhone(normalizedPhone);
            user.setAddress(address != null ? address.trim() : "");
            session.setAttribute("LOGIN_USER", user);
            request.setAttribute("success", "Profile updated successfully!");
        } else {
            request.setAttribute("error", "Failed to update profile. Please try again.");
        }
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }
}
