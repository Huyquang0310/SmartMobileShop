package utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public final class PasswordUtil {
    private static final int ITERATIONS = 180000;
    private static final int KEY_BITS = 256;
    private static final SecureRandom RANDOM = new SecureRandom();

    private PasswordUtil() { }

    public static String generateResetToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public static String hashResetToken(String token) {
        if (token == null || !token.matches("[A-Za-z0-9_-]{40,80}")) return null;
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(token.getBytes(StandardCharsets.US_ASCII));
            return java.util.HexFormat.of().formatHex(digest);
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    public static String hash(String value) {
        if (value == null || value.isEmpty()) throw new IllegalArgumentException("Invalid credential");
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);
        byte[] digest = derive(value, salt, ITERATIONS);
        return "pbkdf2:" + ITERATIONS + ":" + Base64.getEncoder().encodeToString(salt)
                + ":" + Base64.getEncoder().encodeToString(digest);
    }

    public static boolean matches(String input, String stored) {
        if (input == null || stored == null || stored.isEmpty()) return false;
        if (!stored.startsWith("pbkdf2:")) {
            return MessageDigest.isEqual(input.getBytes(StandardCharsets.UTF_8),
                    stored.getBytes(StandardCharsets.UTF_8));
        }
        try {
            String[] parts = stored.split(":", 4);
            if (parts.length != 4) return false;
            int iterations = Integer.parseInt(parts[1]);
            if (iterations < 10000 || iterations > 2000000) return false;
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expected = Base64.getDecoder().decode(parts[3]);
            return MessageDigest.isEqual(derive(input, salt, iterations), expected);
        } catch (RuntimeException e) {
            return false;
        }
    }

    private static byte[] derive(String value, byte[] salt, int iterations) {
        char[] chars = value.toCharArray();
        PBEKeySpec spec = new PBEKeySpec(chars, salt, iterations, KEY_BITS);
        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new IllegalStateException("Unable to process credential", e);
        } finally {
            spec.clearPassword();
            java.util.Arrays.fill(chars, '\0');
        }
    }
}
