# ============================================================
# Pahina Connect - Dockerfile for Railway Deployment
# ============================================================

# Stage 1: Build the WAR file using Maven
FROM maven:3.9.6-eclipse-temurin-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run with Tomcat 10
FROM tomcat:10.1-jdk11-temurin

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR file as ROOT.war (serves at /)
COPY --from=build /app/target/PahinaConnect-1.0.0.war /usr/local/tomcat/webapps/ROOT.war

# Create persistent upload directories
RUN mkdir -p /usr/local/tomcat/pahina_uploads/profiles
RUN mkdir -p /usr/local/tomcat/pahina_uploads/covers
RUN mkdir -p /usr/local/tomcat/pahina_uploads/ebooks

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
