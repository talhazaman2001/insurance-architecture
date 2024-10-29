# Application Load Balancer in Public Subnets
resource "aws_lb" "fargate_alb" {
  name               = "fargate-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.private_subnets

  enable_deletion_protection = false

  tags = {
    Name = "fargate-application-load-balancer"
  }
}

# Security Group for ALB to ensure only trusted traffic from CloudFront reaches ALB through API Gateway
resource "aws_security_group" "alb_sg" {
  name   = "fargate-lb-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.endpoint_sg.id]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.endpoint_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the Target Groups for Blue and Green Deployment
resource "aws_lb_target_group" "fraud_detection_engine_blue_tg" {
    name = "fraud-detection-blue-tg"
    port = 5000
    protocol = "HTTP"
    vpc_id = aws_vpc.main_vpc.id
    target_type = "ip"
    health_check {
      path = "/health"
    }
}

resource "aws_lb_target_group" "fraud_detection_engine_green_tg" {
    name = "fraud-detection-green-tg"
    port = 5000
    protocol = "HTTP"
    vpc_id = aws_vpc.main_vpc.id
    target_type = "ip"
    health_check {
      path = "/health"
    }
}

resource "aws_lb_target_group" "risk_assessment_service_blue_tg" {
    name = "risk-assessment-blue-tg"
    port = 8080
    protocol = "HTTP"
    vpc_id = aws_vpc.main_vpc.id
    target_type = "ip"
    health_check {
      path = "/health"
    }
}

resource "aws_lb_target_group" "risk_assessment_service_green_tg" {
    name = "risk-assessment-green-tg"
    port = 8080
    protocol = "HTTP"
    vpc_id = aws_vpc.main_vpc.id
    target_type = "ip"
    health_check {
      path = "/health"
    }
}

resource "aws_lb_target_group" "claims_processing_service_blue_tg" {
    name = "claims-processing-blue-tg"
    port = 6000
    protocol = "HTTP"
    vpc_id = aws_vpc.main_vpc.id
    target_type = "ip"
    health_check {
      path = "/health"
    }
}

resource "aws_lb_target_group" "claims_processing_service_green_tg" {
    name = "claims-processing-green-tg"
    port = 6000
    protocol = "HTTP"
    vpc_id = aws_vpc.main_vpc.id
    target_type = "ip"
    health_check {
      path = "/health"
    }
}

# Define the listener for Fraud Detection Engnie
resource "aws_lb_listener" "fargate_listener" {
    load_balancer_arn = aws_lb.fargate_alb.arn 
    port = 80          
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.fraud_detection_engine_blue_tg.arn
    }
}

# Listener Rule for Fraud Detection Engine
resource "aws_lb_listener_rule" "fraud_detection_engine_rule" {
  listener_arn = aws_lb_listener.fargate_listener.arn
  priority = 1

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.fraud_detection_engine_blue_tg.arn
  }

  condition {
    path_pattern {
      values = ["/fraud-detection-engine/*"]
    }
  }
}

# Listener Rule for Risk Assessment Service
resource "aws_lb_listener_rule" "risk_assessment_service_rule" {
  listener_arn = aws_lb_listener.fargate_listener.arn
  priority = 2

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.risk_assessment_service_blue_tg.arn
  }

  condition {
    path_pattern {
      values = ["/risk-assessment-service/*"]
    }
  }
}

# Listener Rule for Claims Processing Service
resource "aws_lb_listener_rule" "claims_processing_service_rule" {
  listener_arn = aws_lb_listener.fargate_listener.arn
  priority = 3

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.claims_processing_service_blue_tg.arn
  }

  condition {
    path_pattern {
      values = ["/claims-processing-service/*"]
    }
  }
}
