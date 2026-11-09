package filter;

import dao.UserDAO;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/cart", "/order", "/qa", "/my-qa", "/profile", "/change-password"})
public class SessionSecurityFilter implements Filter {
    private final UserDAO userDAO = new UserDAO();

    @Override
    public void doFilter(ServletRequest rawRequest, ServletResponse rawResponse, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) rawRequest;
        HttpServletResponse response = (HttpServletResponse) rawResponse;
        HttpSession session = request.getSession(false);
        User sessionUser = session == null ? null : (User) session.getAttribute("LOGIN_USER");
        if (sessionUser != null) {
            User current = userDAO.getUserById(sessionUser.getUserId());
            if (current == null || !current.isStatus()) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/auth?action=login");
                return;
            }
            current.setPassword(null);
            session.setAttribute("LOGIN_USER", current);
            sessionUser = current;
        }
        String route = request.getRequestURI().substring(request.getContextPath().length());
        if (route.startsWith("/admin/") && (sessionUser == null || !sessionUser.isAdmin())) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        chain.doFilter(rawRequest, rawResponse);
    }
}
