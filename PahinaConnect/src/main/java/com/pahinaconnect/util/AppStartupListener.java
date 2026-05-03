package com.pahinaconnect.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Runs on application startup to initialize the database.
 * This ensures all tables exist before any request is processed.
 */
@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AppStartupListener] Application starting - initializing database...");
        DatabaseInitializer.initialize();
        System.out.println("[AppStartupListener] Database initialization complete.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AppStartupListener] Application stopping.");
    }
}
