package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store");
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        if (username == null || email == null || username.isBlank() ||
                !email.trim().matches("(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}")) {
            request.setAttribute("error", "Enter your registered username and a valid email address.");
        } else {
            Integer userId = userDAO.findActiveAccountForLocalReset(
                    username.trim(), email.trim().toLowerCase(Locale.ROOT));
            if (userId != null) {
                HttpSession session = request.getSession(true);
                request.changeSessionId();
                session.setAttribute("LOCAL_RESET_USER_ID", userId);
                session.setAttribute("LOCAL_RESET_EXPIRES", System.currentTimeMillis() + 5 * 60 * 1000L);
                response.sendRedirect(request.getContextPath() + "/reset-password");
                return;
            }
            request.setAttribute("error", "Username and email do not match an active account.");
        }
        request.setAttribute("username", username == null ? "" : username.trim());
        request.setAttribute("email", email == null ? "" : email.trim());
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }
}
