package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store");
        if (activeResetUser(request) == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password?expired=1");
            return;
        }
        request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store");
        Integer userId = activeResetUser(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password?expired=1");
            return;
        }
        String password = request.getParameter("newPassword");
        String confirmation = request.getParameter("confirmPassword");
        if (password == null || password.length() < 8 || password.length() > 100 ||
                !password.equals(confirmation)) {
            request.setAttribute("error", "Use matching passwords of 8 to 100 characters.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        if (userDAO.resetPasswordForLocalDemo(userId, password)) {
            clearReset(request.getSession(false));
            response.sendRedirect(request.getContextPath() + "/auth?action=login&reset=success");
        } else {
            clearReset(request.getSession(false));
            response.sendRedirect(request.getContextPath() + "/forgot-password?expired=1");
        }
    }

    private Integer activeResetUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object id = session.getAttribute("LOCAL_RESET_USER_ID");
        Object expires = session.getAttribute("LOCAL_RESET_EXPIRES");
        if (!(id instanceof Integer) || !(expires instanceof Long) ||
                System.currentTimeMillis() >= (Long) expires) {
            clearReset(session);
            return null;
        }
        return (Integer) id;
    }

    private void clearReset(HttpSession session) {
        if (session != null) {
            session.removeAttribute("LOCAL_RESET_USER_ID");
            session.removeAttribute("LOCAL_RESET_EXPIRES");
        }
    }
}
