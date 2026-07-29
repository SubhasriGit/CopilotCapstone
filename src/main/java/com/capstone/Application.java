package com.capstone;

import com.capstone.security.ConnectionValidator;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;

@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        ApplicationContext ctx = SpringApplication.run(Application.class, args);
        // Validate all connections at startup — fail fast if critical connection is down
        ConnectionValidator validator = ctx.getBean(ConnectionValidator.class);
        validator.validateAll();
    }
}
