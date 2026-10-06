resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Default action if no path matches
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Service Not Found"
      status_code  = "404"
    }
  }
}

locals {
  service_ports = {
    "order"        = 8080
    "inventory"    = 8081
    "payment"      = 8082
    "notification" = 8083
  }
}

resource "aws_lb_target_group" "services" {
  for_each    = local.service_ports
  name        = "${var.project_name}-tg-${each.key}"
  port        = each.value
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    # Assuming Spring Boot actuator. If not, change to "/" or a valid health endpoint
    path                = "/actuator/health" 
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

# Route traffic based on URL path prefix e.g. /api/order -> order service
resource "aws_lb_listener_rule" "services" {
  for_each     = local.service_ports
  listener_arn = aws_lb_listener.http.arn
  # Give each rule a unique priority
  priority     = index(keys(local.service_ports), each.key) + 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/api/${each.key}*"]
    }
  }
}

# Register our single EC2 instance to all 4 target groups on their respective ports
resource "aws_lb_target_group_attachment" "services" {
  for_each         = local.service_ports
  target_group_arn = aws_lb_target_group.services[each.key].arn
  target_id        = aws_instance.app_server.id
  port             = each.value
}
