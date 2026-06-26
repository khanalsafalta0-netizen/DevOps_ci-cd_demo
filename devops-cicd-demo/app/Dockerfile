# Stage 1: Build the jar with Maven
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run it on a small JRE base image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /build/target/devops-cicd-demo.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
