#!/bin/bash

# Navigate to terraform directory and get the ALB DNS name
cd terraform || exit
ALB_URL=$(terraform output -raw alb_dns_name 2>/dev/null)

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
echo "--- Database Credentials (H2) ---"
echo "Username: sa"
echo "Password: your_secret_password"
echo "========================================="
