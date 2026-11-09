package controller;

import dao.QaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import utils.QaStatusFilter;
import java.io.IOException;

@WebServlet("/my-qa")
public class MyQaServlet extends HttpServlet {
    private QaDAO qaDAO;

    @Override
    public void init() throws ServletException {
        qaDAO = new QaDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        String status = QaStatusFilter.normalize(request.getParameter("status"));
        request.setAttribute("selectedStatus", status);
        request.setAttribute("conversations", QaStatusFilter.filter(qaDAO.getMyConversations(user.getUserId()), status));
        request.getRequestDispatcher("/my-qa.jsp").forward(request, response);
    }
}
