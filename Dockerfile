# ─────────────────────────────────────────────────────────────
# Stage 1: Build
# Uses Maven + Amazon Corretto 20 to compile and package the JAR
# ─────────────────────────────────────────────────────────────
FROM maven:3.9.9-amazoncorretto-20 AS build

WORKDIR /build

# Cache dependencies layer separately (faster rebuilds)
COPY pom.xml .
RUN mvn dependency:go-offline -q

COPY src ./src
RUN mvn clean package -DskipTests -q

# ─────────────────────────────────────────────────────────────
# Stage 2: Runtime
# Minimal Amazon Corretto 20 image — no build tools
# ─────────────────────────────────────────────────────────────
FROM amazoncorretto:20-alpine3.19

WORKDIR /app

# Non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=build /build/target/github-copilot-capstone-*.jar app.jar

# Render injects PORT env var; Spring Boot reads PORT → SERVER_PORT → APP_PORT fallback
ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
  CMD wget -qO- http://localhost:${PORT}/health || exit 1

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
