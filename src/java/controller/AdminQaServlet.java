package controller;

import dao.QaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Question;
import model.Answer;
import model.User;
import utils.QaStatusFilter;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/admin/qa")
public class AdminQaServlet extends HttpServlet {
    private QaDAO qaDAO;

    @Override
    public void init() throws ServletException {
        qaDAO = new QaDAO();
    }

    private User requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("LOGIN_USER");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return null;
        }
        return user;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (requireAdmin(request, response) == null) return;
        List<Question> conversations = qaDAO.getAllConversations();
        int pendingQuestions = 0;
        int pendingAnswers = 0;
        for (Question question : conversations) {
            boolean pending = "Pending".equals(question.getStatus());
            if (pending) pendingQuestions++;
            for (Answer answer : question.getAnswers()) {
                if ("Pending".equals(answer.getStatus())) {
                    pendingAnswers++;
                    pending = true;
                }
            }
        }
        String requested = request.getParameter("status");
        if (requested == null) requested = request.getParameter("view");
        String status = QaStatusFilter.normalize(requested);
        request.setAttribute("conversations", QaStatusFilter.filter(conversations, status));
        request.setAttribute("totalConversations", conversations.size());
        request.setAttribute("pendingQuestions", pendingQuestions);
        request.setAttribute("pendingAnswers", pendingAnswers);
        request.setAttribute("selectedStatus", status);
        request.getRequestDispatcher("/admin/qa.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requireAdmin(request, response);
        if (user == null) return;
        String action = request.getParameter("action");
        boolean ok = false;
        int questionId = 0;
        String message;
        if ("reply".equals(action)) {
            questionId = safeId(request.getParameter("questionId"));
            String content = request.getParameter("content");
            if (questionId > 0 && content != null && content.trim().length() >= 5
                    && content.trim().length() <= 2000) {
                ok = qaDAO.reply(questionId, user.getUserId(), content.trim(), true);
                message = ok ? "Reply published." : "Unable to publish reply.";
            } else {
                message = "Reply must be 5 to 2000 characters.";
            }
        } else {
            int id = safeId(request.getParameter("id"));
            if (id > 0) {
                String type = request.getParameter("type");
                if ("question".equals(type)) questionId = id;
                else if ("answer".equals(type)) {
                    for (Question q : qaDAO.getAllConversations()) {
                        for (Answer a : q.getAnswers()) {
                            if (a.getAnswerId() == id) questionId = q.getQuestionId();
                        }
                    }
                }
                ok = qaDAO.moderate(type, id, action);
            }
            message = ok ? "Content updated." : "Unable to update content.";
        }
        String status = QaStatusFilter.normalize(request.getParameter("status"));
        response.sendRedirect(request.getContextPath() + "/admin/qa?status=" + status
                + "&" + (ok ? "message=" : "error=") + URLEncoder.encode(message, StandardCharsets.UTF_8)
                + (questionId > 0 ? "#thread-" + questionId : ""));
    }

    private int safeId(String raw) {
        try { return Math.max(0, Integer.parseInt(raw)); }
        catch (Exception ex) { return 0; }
    }
}
