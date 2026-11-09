package utils;

import jakarta.persistence.EntityManager;

/**
 * Standalone smoke test for the JPA connection.
 * Run this only after the dependencies and persistence.xml are on the classpath.
 */
public class TestConnection {

    public static void main(String[] args) {
        System.out.println("Starting JPA connection test...");

        try (EntityManager entityManager = JPAUtil.getEntityManager()) {
            Object result = entityManager.createNativeQuery("SELECT 1").getSingleResult();
            System.out.println("Success! JPA connected to SQL Server.");
            System.out.println("Test query result: " + result);
        } catch (Exception e) {
            System.err.println("JPA connection test failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            JPAUtil.close();
        }
    }
}
