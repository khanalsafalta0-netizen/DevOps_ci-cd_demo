package com.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class AppTest {

    @LocalServerPort
    private int port;

    @Test
    void homeEndpointReturnsExpectedMessage() {
        TestRestTemplate restTemplate = new TestRestTemplate();
        String url = "http://localhost:" + port + "/";
        String response = restTemplate.getForObject(url, String.class);
        assertThat(response).contains("DevOps CI/CD Demo is live");
    }

    @Test
    void versionEndpointReturnsVersionInfo() {
        TestRestTemplate restTemplate = new TestRestTemplate();
        String url = "http://localhost:" + port + "/version";
        String response = restTemplate.getForObject(url, String.class);
        assertThat(response).contains("App version: 1.0.0");
    }
}
