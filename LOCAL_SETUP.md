# Local Setup Guide

This guide contains all the essential commands and URLs to run and manage the E-commerce Saga Microservices locally.

## 🛠️ Docker Commands

Start everything in the background (builds the images if necessary):
```bash
docker compose up --build -d
```

View the live streaming logs for all containers:
```bash
docker compose logs -f
```

View logs for a specific service (e.g., `order-service`):
```bash
docker compose logs -f order-service
```

Stop and remove all running containers:
```bash
docker compose down
```

---

## 🔗 Useful URLs

### 1. Kafka UI
Monitor Kafka topics, messages, and consumer groups in real-time.
*   **Kafka UI:** [http://localhost:8080](http://localhost:8080)

### 2. Swagger UI (API Documentation)
Interact with the REST APIs directly from your browser.
*   **Order Service:** [http://localhost:8081/swagger-ui/index.html](http://localhost:8081/swagger-ui/index.html)
*   **Inventory Service:** [http://localhost:8082/swagger-ui/index.html](http://localhost:8082/swagger-ui/index.html)
*   **Payment Service:** [http://localhost:8083/swagger-ui/index.html](http://localhost:8083/swagger-ui/index.html)
*   **Notification Service:** [http://localhost:8084/swagger-ui/index.html](http://localhost:8084/swagger-ui/index.html)

### 3. H2 Database Web Consoles
View the internal state of each microservice's in-memory database. 

**Login Credentials for all databases:**
*   **User Name:** `sa`
*   **Password:** `your_secret_password` (or whatever you set in your `.env` file)

**Database Specific URLs & JDBC Settings:**
*   **Order Service DB:** [http://localhost:8081/h2-console](http://localhost:8081/h2-console)
    *   *JDBC URL:* `jdbc:h2:mem:orderdb`
*   **Inventory Service DB:** [http://localhost:8082/h2-console](http://localhost:8082/h2-console)
    *   *JDBC URL:* `jdbc:h2:mem:inventorydb`
*   **Payment Service DB:** [http://localhost:8083/h2-console](http://localhost:8083/h2-console)
    *   *JDBC URL:* `jdbc:h2:mem:paymentdb`
*   **Notification Service DB:** [http://localhost:8084/h2-console](http://localhost:8084/h2-console)
    *   *JDBC URL:* `jdbc:h2:mem:notificationdb`

---

## 🧪 Testing the Saga Process
You can trigger the entire distributed transaction by creating an order using curl:

```bash
curl -X POST http://localhost:8081/api/orders \
-H "Content-Type: application/json" \
-d '{"customerId": "user123", "productId": "prod-1", "quantity": 1}'
```
*(You can also run this request visually via the Order Service Swagger UI!)*
