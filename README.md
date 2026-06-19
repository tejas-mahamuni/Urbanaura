# UrbanAura Pune

UrbanAura Pune is a smart-city analytics and livability dashboard built with Spring Boot. It combines relational property data, realtime AQI telemetry, and AI-assisted consultation into a single web application focused on urban decision support.

## Stack

- Java 17
- Spring Boot 3
- Spring MVC + JSP
- Spring Data JPA + MySQL
- Spring Data MongoDB
- Spring Security
- STOMP over WebSockets + SockJS
- Spring AI + Gemini
- Apache POI
- iText 7

## Architecture

- `MySQL`
  Source of truth for localities, properties, smart metrics, quick commerce, users, and relational joins.
- `MongoDB`
  Stores AQI heartbeat logs and AI consultation history.
- `property_id`
  Acts as the shared anchor across relational and document-backed workflows.

## Key Features

- Realtime AQI simulation and broadcast through WebSockets
- Role-based login and admin-gated report/export flow
- AI consultant with grounded database context
- Excel-based seed loading for locality/property datasets
- Multithreaded SDG-style sustainability report generation

## Quick Start

1. Start MySQL (port 3307) and MongoDB (port 27017) locally.
2. Clone the repository and navigate to the project directory.
3. Run the application:

```powershell
$env:MYSQL_URL="jdbc:mysql://localhost:3307/urbanaura?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
$env:MYSQL_USERNAME="root"
$env:MYSQL_PASSWORD="root"
$env:MONGODB_URI="mongodb://admin:password@localhost:27017/urbanaura?authSource=admin"
$env:URBANAURA_ADMIN_USERNAME="admin"
$env:URBANAURA_ADMIN_PASSWORD="admin123"
$env:URBANAURA_USER_USERNAME="user"
$env:URBANAURA_USER_PASSWORD="user123"
```

3. Compile or run:

```powershell
./mvnw -q -DskipTests compile
./mvnw spring-boot:run
```

4. Open `http://localhost:8081`
5. Load seed data from `http://localhost:8081/admin/load-data` after signing in as admin

## Auth

Default seeded accounts:

- `admin / admin123`
- `user / user123`

These are seeded into the relational `users` table on startup if missing. Replace them through environment variables for demos or deployment.

## Verification Strategy

Use lightweight checks first:

```powershell
./mvnw -q -DskipTests compile
./mvnw -q -DskipTests test-compile
```

Avoid running the full suite on constrained machines unless needed.

## Current Notes

- The loader is optimized for Excel-imported assigned IDs.
- WebSocket and AI endpoints require authentication.
- Actuator exposes `health`, `info`, and `metrics`.
