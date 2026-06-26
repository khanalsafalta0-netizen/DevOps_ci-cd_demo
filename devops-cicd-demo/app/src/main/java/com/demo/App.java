package com.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@SpringBootApplication
@RestController
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @GetMapping("/")
    public String home() {
        return "DevOps CI/CD Demo is live! Deployed via Jenkins + Docker + Terraform on AWS EC2.";
    }

    @GetMapping("/version")
    public String version() {
        return "App version: 1.0.0 | Build time: " + LocalDateTime.now();
    }
}
