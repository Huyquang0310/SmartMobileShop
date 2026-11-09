package utils;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Closes the shared JPA factory when Tomcat undeploys the application.
 */
@WebListener
public class JpaLifecycleListener implements ServletContextListener {

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        JPAUtil.close();
    }
}
