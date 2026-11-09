package utils;

import java.util.ArrayList;
import java.util.List;
import model.Answer;
import model.Question;

public final class QaStatusFilter {
    private QaStatusFilter() { }

    public static String normalize(String input) {
        return switch (input == null ? "" : input.toLowerCase()) {
            case "pending", "approved", "rejected" -> input.toLowerCase();
            default -> "all";
        };
    }

    public static List<Question> filter(List<Question> conversations, String status) {
        String selected = normalize(status);
        if ("all".equals(selected)) return conversations;
        List<Question> results = new ArrayList<>();
        for (Question question : conversations) {
            if (matches(question, selected)) results.add(question);
        }
        return results;
    }

    public static boolean matches(Question question, String status) {
        if (question == null) return false;
        boolean pending = "Pending".equals(question.getStatus());
        boolean rejected = "Rejected".equals(question.getStatus());
        if (question.getAnswers() != null) {
            for (Answer answer : question.getAnswers()) {
                if ("Pending".equals(answer.getStatus())) pending = true;
                if ("Rejected".equals(answer.getStatus())) rejected = true;
            }
        }
        return switch (normalize(status)) {
            case "pending" -> pending;
            case "rejected" -> rejected;
            case "approved" -> "Approved".equals(question.getStatus()) && !pending && !rejected;
            default -> true;
        };
    }
}
