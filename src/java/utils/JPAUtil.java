package utils;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.persistence.EntityTransaction;
import java.util.function.Supplier;
import java.util.HashMap;
import java.util.Map;

/**
 * Creates EntityManager instances for DAO operations.
 * EntityManagerFactory is shared for the lifetime of the web application.
 */
public final class JPAUtil {

    private static final EntityManagerFactory ENTITY_MANAGER_FACTORY = initialize();

    private static EntityManagerFactory initialize() {
        Map<String, Object> options = new HashMap<>();
        String url = setting("smartshop.db.url", "SMARTSHOP_DB_URL");
        String username = setting("smartshop.db.user", "SMARTSHOP_DB_USER");
        String password = setting("smartshop.db.password", "SMARTSHOP_DB_PASSWORD");
        String driver = setting("smartshop.db.driver", "SMARTSHOP_DB_DRIVER");
        String platform = setting("smartshop.db.platform", "SMARTSHOP_DB_PLATFORM");
        if (driver != null) options.put("jakarta.persistence.jdbc.driver", driver);
        if (platform != null) options.put("eclipselink.target-database", platform);
        if (url != null) options.put("jakarta.persistence.jdbc.url", url);
        if (username != null) options.put("jakarta.persistence.jdbc.user", username);
        if (password != null) options.put("jakarta.persistence.jdbc.password", password);
        return Persistence.createEntityManagerFactory("SmartMobileShopPU", options);
    }

    private static String setting(String propertyName, String environmentName) {
        String value = System.getProperty(propertyName);
        return value != null ? value : System.getenv(environmentName);
    }

    private JPAUtil() {
        // Utility class: do not create instances.
    }

    public static EntityManager getEntityManager() {
        if (!ENTITY_MANAGER_FACTORY.isOpen()) {
            throw new IllegalStateException("JPA EntityManagerFactory is already closed.");
        }
        return ENTITY_MANAGER_FACTORY.createEntityManager();
    }

    /**
     * Runs one database write operation in a transaction.
     */
    public static <T> T inTransaction(EntityManager entityManager, Supplier<T> operation) {
        EntityTransaction transaction = entityManager.getTransaction();

        try {
            transaction.begin();
            T result = operation.get();
            transaction.commit();
            return result;
        } catch (RuntimeException exception) {
            if (transaction.isActive()) {
                transaction.rollback();
            }
            throw exception;
        }
    }

    public static void close() {
        if (ENTITY_MANAGER_FACTORY.isOpen()) {
            ENTITY_MANAGER_FACTORY.close();
        }
    }
}
