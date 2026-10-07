#!/bin/bash

# If ALB_URL is not set (e.g. by Terraform local-exec), fetch it manually
if [ -z "$ALB_URL" ]; then
    ALB_URL=$(terraform output -raw alb_dns_name 2>/dev/null)
fi

if [ -z "$ALB_URL" ]; then
    echo "Could not fetch ALB URL. Make sure Terraform has been applied successfully."
    ALB_URL="<YOUR_ALB_DNS_NAME>"
fi

echo "========================================="
echo "        EcomSaga Live Endpoints          "
echo "========================================="
echo "Application Load Balancer Base URL:"
echo "http://${ALB_URL}"
echo ""
echo "--- Microservice Endpoints ---"
echo "Order API:        http://${ALB_URL}/api/order"
echo "Order Swagger:    http://${ALB_URL}/api/order/swagger-ui/index.html"
echo ""
echo "Inventory API:    http://${ALB_URL}/api/inventory"
echo "Inventory Swagger:http://${ALB_URL}/api/inventory/swagger-ui/index.html"
echo ""
echo "Payment API:      http://${ALB_URL}/api/payment"
echo "Payment Swagger:  http://${ALB_URL}/api/payment/swagger-ui/index.html"
echo ""
echo "Notification API: http://${ALB_URL}/api/notification"
echo "Notification Swag:http://${ALB_URL}/api/notification/swagger-ui/index.html"
echo ""

if [ -z "$EC2_IP" ]; then
    EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
fi
if [ -n "$EC2_IP" ]; then
    echo "--- Kafka Infrastructure ---"
    echo "Kafka UI:         http://${EC2_IP}:8084"
    echo ""
fi

if [ -z "$MONITORING_IP" ]; then
    MONITORING_IP=$(terraform output -raw monitoring_public_ip 2>/dev/null)
fi
if [ -n "$MONITORING_IP" ]; then
    echo "--- Monitoring Infrastructure ---"
    echo "Grafana:          http://${MONITORING_IP}:3000"
    echo "  Username:       admin"
    echo "  Password:       admin"
    echo "Prometheus:       http://${MONITORING_IP}:9090"
    echo ""
    echo "--- Connecting Data Sources in Grafana ---"
    echo "1. Prometheus: Go to Data Sources -> Add Prometheus"
    echo "   URL: http://prometheus:9090"
    echo "2. Loki: Go to Data Sources -> Add Loki"
    echo "   URL: http://loki:3100"
    echo ""
fi

echo "--- Database Credentials (H2) ---"
echo "Order DB:         http://${ALB_URL}/api/order/h2-console"
echo "  JDBC URL:       jdbc:h2:mem:orderdb"
echo "Inventory DB:     http://${ALB_URL}/api/inventory/h2-console"
echo "  JDBC URL:       jdbc:h2:mem:inventorydb"
echo "Payment DB:       http://${ALB_URL}/api/payment/h2-console"
echo "  JDBC URL:       jdbc:h2:mem:paymentdb"
echo "Notification DB:  http://${ALB_URL}/api/notification/h2-console"
echo "  JDBC URL:       jdbc:h2:mem:notificationdb"
echo ""
echo "Username: root"
echo "Password: root"
echo "========================================="
