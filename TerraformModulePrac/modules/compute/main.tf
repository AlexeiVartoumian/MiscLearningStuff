
data "aws_ami" "amzon_linux_2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_launch_template" "webapp" {
    name_prefix = "webapp-"

    image_id = data.aws_ami.amazon_linux2.id
    instance_type = var.instance_type
    key_name = var.key_name

    network_interfaces {
        associate_public_ip_address = true
        security_groups = [var.web_server_sg_id]
    }

    user_data = base64encode(<<-EOF
                #!/bin/bash
                yum update -y
                yum install - y httpd
                systemctl start httpd
                systemctl enable httpd
                echo"<h1> hello there terrafrom prog" </h1> > /var/www/html.index.html
                EOF
    )
}

resource "aws_autoscaling_group" "webapp" {
    name = "webapp-asg"

    vpc_zone_identifier = var.public_subnet_ids
    target_group_arns = [aws_lb_target_group.webapp.arn]
    health_check_type = "ELB"

    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = avr.desired_capacity
    health_check_grace_period = var.helath_check_grace_period = var.health_check_grace_period

    launch_template {
        id = aws_launch_template.webapp.id
        version = "$latest"

        tag {
            key = "Name"
            value = "webapp-instance"
            propagate_at_launch = true
        }
    }
}

resource "aws_lb" "webapp" {
    name = "webapp-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.web_server_sg_id]
    subnets = var.public_subnet_ids
    tags = {
        Name = "webapp-alb"
    } 
}

resource "aws_lb_listener" "webapp" {
    load_balancer_arn = aws_lb.webapp.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.webapp.arn
    }
}

resource "aws_lb_target_group" "webapp" {
    name = "webapp-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id

    health_check {
        path = "/"
        healthy_threshold = 2

        unhealthy_threshold = 10
    }
}
