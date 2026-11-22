
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "mb_alb_sg" {
  name        = "mb-project16-alb-sg"
  description = "Project 16 ALB - HTTPS only"
  vpc_id      = var.vpc_id

  ingress {
    description = "Public HTTPS only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Forward HTTP to backend within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  tags = {
    Name = "mb-project16-alb-sg"
  }
}

resource "aws_security_group" "mb_ec2_sg" {
  name        = "mb-project16-ec2-sg"
  description = "Project 16 EC2 - HTTP only from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from our ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.mb_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mb-project16-ec2-sg"
  }
}

resource "aws_instance" "mb_web_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_a
  vpc_security_group_ids      = [aws_security_group.mb_ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>MB - Project 16 HTTPS Server</h1>" > /usr/share/nginx/html/index.html
  EOF

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "mb-project16-https-server"
  }
}

resource "aws_lb_target_group" "mb_tg" {
  name        = "mb-project16-https-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "mb-project16-https-tg"
  }
}

resource "aws_lb_target_group_attachment" "mb_attachment" {
  target_group_arn = aws_lb_target_group.mb_tg.arn
  target_id        = aws_instance.mb_web_server.id
  port             = 80
}

resource "aws_lb" "mb_alb" {
  name               = "mb-project16-https-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.mb_alb_sg.id]

  subnets = [
    var.subnet_a,
    var.subnet_b
  ]

  tags = {
    Name = "mb-project16-https-alb"
  }
}
resource "aws_lb_listener" "mb_https" {
  load_balancer_arn = aws_lb.mb_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mb_tg.arn
  }

  tags = {
    Name = "mb-project16-https-listener"
  }
}
