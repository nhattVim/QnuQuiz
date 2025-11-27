# Build Stage
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app

# Copy maven wrapper and properties first for better caching
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw

# Download Dependencies (cached)
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw dependency:go-offline

# Copy Source code
COPY src/main ./src/main

# Build application
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw clean package -DskipTests \
    -Dtomcat.version=10.1.49 \
    -Dspring-boot.version=6.2.14

# Extract the application deps
RUN jar xf target/*.jar

# Analyze dependencies for custom JRE
RUN jdeps --ignore-missing-deps -q \
    --recursive \
    --multi-release 21 \
    --print-module-deps \
    --class-path 'BOOT-INF/lib/*' \
    target/*.jar > deps.info

# Create the custom JRE
RUN jlink \
    --verbose \
    --add-modules $(cat deps.info) \
    --compress zip-9 \
    --no-header-files \
    --no-man-pages \
    --output /custom_jre

# Runtime Stage
FROM gcr.io/distroless/base-debian12
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"
COPY --from=builder /custom_jre $JAVA_HOME

WORKDIR /app

# Copy Compiled app
COPY --from=builder /app/target/*.jar app.jar

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

ENTRYPOINT ["java", "-jar", "app.jar"]
