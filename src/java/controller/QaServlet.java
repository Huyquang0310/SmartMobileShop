package controller;

import dao.QaDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Question;
import model.User;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/qa")
public class QaServlet extends HttpServlet {
    private QaDAO qaDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        qaDAO = new QaDAO();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        String content = request.getParameter("content");
        if (content == null || content.trim().length() < 5 || content.trim().length() > 2000) {
            redirect(request, response, safeId(request.getParameter("productId")), 0,
                    "Content must be 5 to 2000 characters.", false);
            return;
        }
        String action = request.getParameter("action");
        boolean success = false;
        int productId = safeId(request.getParameter("productId"));
        int threadId = safeId(request.getParameter("questionId"));
        if (productId <= 0 || productDAO.getVisibleProductById(productId) == null) {
            redirect(request, response, productId, threadId, "This product is no longer available.", false);
            return;
        }
        if ("ask".equals(action) && productId > 0) {
            success = qaDAO.ask(productId, user.getUserId(), content.trim(), user.isAdmin());
        } else if ("reply".equals(action)) {
            int questionId = safeId(request.getParameter("questionId"));
            Question q = questionId > 0 ? qaDAO.getQuestion(questionId) : null;
            if (q != null && q.getProductId() == productId) {
                success = qaDAO.reply(questionId, user.getUserId(), content.trim(), user.isAdmin());
            }
        }
        redirect(request, response, productId, threadId,
                success ? (user.isAdmin() ? "Your content has been published." : "Submitted for moderation. You can follow its status in My Q&A.")
                        : "Unable to submit Q&A content.", success);
    }

    private void redirect(HttpServletRequest request, HttpServletResponse response,
                          int productId, int questionId, String message, boolean success) throws IOException {
        boolean fromHistory = "history".equals(request.getParameter("returnTo"));
        String path = fromHistory ? "/my-qa" : productId > 0
                ? "/product-details?id=" + productId : "/home";
        String separator = path.contains("?") ? "&" : "?";
        String anchor = fromHistory && questionId > 0 ? "#thread-" + questionId
                : productId > 0 ? "#questions" : "";
        response.sendRedirect(request.getContextPath() + path + separator
                + (success ? "message=" : "error=") + URLEncoder.encode(message, StandardCharsets.UTF_8)
                + anchor);
    }

    private int safeId(String value) {
        try { return Math.max(0, Integer.parseInt(value)); }
        catch (Exception e) { return 0; }
    }
}
