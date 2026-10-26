# Etapa 1: Build (Compilación y Empaquetado)
FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copiar configuración de dependencias para aprovechar la caché de Docker
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar el código fuente y empaquetar el JAR (omitiendo tests ya validados)
COPY src ./src
RUN mvn package -DskipTests -B

# Etapa 2: Runtime (Imagen final ligera)
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app

# Crear usuario sin privilegios por seguridad
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copiar solo el artefacto JAR de la etapa de compilación
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8098

ENTRYPOINT ["java", "-jar", "app.jar"]