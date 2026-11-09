package dao;

import jakarta.persistence.EntityManager;
import model.Answer;
import model.Question;
import utils.JPAUtil;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class QaDAO {
    public List<Question> getPublishedForProduct(int productId) {
        return getVisibleForProduct(productId, 0, false);
    }

    public List<Question> getVisibleForProduct(int productId, int viewerId, boolean admin) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            String jpql = "SELECT q, u.fullName FROM ShopQuestion q, UserEntity u "
                    + "WHERE q.userId = u.userId AND q.productId = :productId "
                    + (admin ? "" : "AND (q.status = 'Approved' OR q.userId = :viewerId) ")
                    + "ORDER BY q.createdAt DESC, q.questionId DESC";
            var query = em.createQuery(jpql, Object[].class).setParameter("productId", productId);
            if (!admin) query.setParameter("viewerId", viewerId);
            List<Question> questions = new ArrayList<>();
            for (Object[] row : query.getResultList()) {
                Question question = (Question) row[0];
                question.setAuthorName((String) row[1]);
                questions.add(question);
            }
            attachAnswers(em, questions, viewerId, admin);
            return questions;
        }
    }

    public List<Question> getMyConversations(int userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                    "SELECT q, u.fullName, p.productName FROM ShopQuestion q, UserEntity u, ShopProduct p "
                    + "WHERE q.userId = u.userId AND q.productId = p.productId "
                    + "AND (q.userId = :userId OR (q.status = 'Approved' AND EXISTS "
                    + "(SELECT a.answerId FROM ShopAnswer a WHERE a.questionId = q.questionId "
                    + "AND a.userId = :userId))) "
                    + "ORDER BY q.createdAt DESC, q.questionId DESC", Object[].class)
                    .setParameter("userId", userId).getResultList();
            List<Question> questions = new ArrayList<>();
            for (Object[] row : rows) {
                Question question = (Question) row[0];
                question.setAuthorName((String) row[1]);
                question.setProductName((String) row[2]);
                questions.add(question);
            }
            attachAnswers(em, questions, userId, false);
            return questions;
        }
    }

    public List<Question> getAllConversations() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                    "SELECT q, u.fullName, p.productName FROM ShopQuestion q, UserEntity u, ShopProduct p "
                    + "WHERE q.userId = u.userId AND q.productId = p.productId "
                    + "ORDER BY q.createdAt DESC, q.questionId DESC", Object[].class).getResultList();
            List<Question> questions = new ArrayList<>();
            for (Object[] row : rows) {
                Question question = (Question) row[0];
                question.setAuthorName((String) row[1]);
                question.setProductName((String) row[2]);
                questions.add(question);
            }
            attachAnswers(em, questions, 0, true);
            return questions;
        }
    }

    private void attachAnswers(EntityManager em, List<Question> questions, int viewerId, boolean admin) {
        if (questions.isEmpty()) return;
        List<Integer> questionIds = new ArrayList<>();
        Map<Integer, Question> byId = new HashMap<>();
        for (Question question : questions) {
            question.setAnswers(new ArrayList<>());
            questionIds.add(question.getQuestionId());
            byId.put(question.getQuestionId(), question);
        }
        String jpql = "SELECT a, u.fullName FROM ShopAnswer a, UserEntity u "
                + "WHERE a.userId = u.userId AND a.questionId IN :questionIds "
                + (admin ? "" : "AND (a.status = 'Approved' OR a.userId = :viewerId) ")
                + "ORDER BY a.createdAt ASC, a.answerId ASC";
        var query = em.createQuery(jpql, Object[].class).setParameter("questionIds", questionIds);
        if (!admin) query.setParameter("viewerId", viewerId);
        for (Object[] row : query.getResultList()) {
            Answer answer = (Answer) row[0];
            answer.setAuthorName((String) row[1]);
            Question question = byId.get(answer.getQuestionId());
            if (question != null) question.getAnswers().add(answer);
        }
    }

    public Question getQuestion(int id) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.find(Question.class, id);
        }
    }

    public boolean ask(int productId, int userId, String content, boolean admin) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Long count = em.createQuery("SELECT COUNT(p) FROM ShopProduct p WHERE p.productId = :id AND p.status = true", Long.class)
                        .setParameter("id", productId).getSingleResult();
                if (count == 0) return false;
                Question q = new Question();
                q.setProductId(productId);
                q.setUserId(userId);
                q.setContent(content);
                q.setStatus(admin ? "Approved" : "Pending");
                em.persist(q);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Unable to create question: " + e.getMessage());
            return false;
        }
    }

    public boolean reply(int questionId, int userId, String content, boolean admin) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                Question q = em.find(Question.class, questionId);
                if (q == null || (!admin && !"Approved".equals(q.getStatus()))) return false;
                Answer a = new Answer();
                a.setQuestionId(questionId);
                a.setUserId(userId);
                a.setContent(content);
                a.setStatus(admin ? "Approved" : "Pending");
                em.persist(a);
                return true;
            });
        } catch (RuntimeException e) {
            System.err.println("Unable to create answer: " + e.getMessage());
            return false;
        }
    }

    public List<Question> getAllQuestions() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                "SELECT q, u.fullName, p.productName FROM ShopQuestion q, UserEntity u, ShopProduct p " +
                "WHERE q.userId = u.userId AND q.productId = p.productId " +
                "ORDER BY q.createdAt DESC, q.questionId DESC", Object[].class).getResultList();
            List<Question> result = new ArrayList<>();
            for (Object[] row : rows) {
                Question q = (Question) row[0];
                q.setAuthorName((String) row[1]);
                q.setProductName((String) row[2]);
                result.add(q);
            }
            return result;
        }
    }

    public List<Answer> getAllAnswers() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Object[]> rows = em.createQuery(
                "SELECT a, u.fullName FROM ShopAnswer a, UserEntity u " +
                "WHERE a.userId = u.userId ORDER BY a.createdAt DESC, a.answerId DESC", Object[].class).getResultList();
            List<Answer> result = new ArrayList<>();
            for (Object[] row : rows) {
                Answer answer = (Answer) row[0];
                answer.setAuthorName((String) row[1]);
                result.add(answer);
            }
            return result;
        }
    }

    public boolean moderate(String type, int id, String action) {
        if (action == null || !List.of("approve", "reject", "delete").contains(action)) return false;
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return JPAUtil.inTransaction(em, () -> {
                if ("question".equals(type)) {
                    Question q = em.find(Question.class, id);
                    if (q == null) return false;
                    if ("delete".equals(action)) {
                        em.createQuery("DELETE FROM ShopAnswer a WHERE a.questionId = :id")
                                .setParameter("id", id).executeUpdate();
                        em.remove(q);
                    } else {
                        q.setStatus("approve".equals(action) ? "Approved" : "Rejected");
                    }
                    return true;
                }
                if ("answer".equals(type)) {
                    Answer answer = em.find(Answer.class, id);
                    if (answer == null) return false;
                    if ("delete".equals(action)) em.remove(answer);
                    else answer.setStatus("approve".equals(action) ? "Approved" : "Rejected");
                    return true;
                }
                return false;
            });
        } catch (RuntimeException e) {
            System.err.println("Unable to moderate Q&A: " + e.getMessage());
            return false;
        }
    }
}
