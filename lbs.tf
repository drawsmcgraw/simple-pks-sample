# Web Load Balancer

# PKS API Load Balancer
##resource "aws_elb" "pks-api" {
##  name = "${var.environment_name}-pks-api"
##  availability_zones = var.availability_zones
##  subnets = aws_subnet.public-subnet[*].id
##
##  instances = [aws_instance.ops-manager.id]
##
##  health_check {
##    healthy_threshold = 10
##    interval = 30
##    target = "tcp:9021"
##    timeout = 5
##    unhealthy_threshold = 2
##  }
##  listener {
##    instance_port = 8443
##    instance_protocol = "tcp"
##    lb_port = 8443
##    lb_protocol = "tcp"
##  }
##  listener {
##    instance_port = 9021
##    instance_protocol = "tcp"
##    lb_port = 9021
##    lb_protocol = "tcp"
##  }
##}

###
# PKS API Load Balancer
# i.e. 'pks-api.domain.com'
###
resource "aws_lb" "pks-api" {
  name                             = "${var.environment_name}-pks-api"
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  internal                         = false
  subnets                          = aws_subnet.public-subnet[*].id
}

# Each 'listener' has a 'target group' behind it.
# We create a listener and a target group for each necessary
# port. In this case, 9021 and 8443.

resource "aws_lb_listener" "pks-api-9021" {
  load_balancer_arn = aws_lb.pks-api.arn
  port              = 9021
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pks-api-9021.arn
  }
}

resource "aws_lb_target_group" "pks-api-9021" {
  name     = "${var.environment_name}-pks-tg-9021"
  port     = 9021
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = 6
    unhealthy_threshold = 6
    interval            = 10
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "pks-api-8443" {
  load_balancer_arn = aws_lb.pks-api.arn
  port              = 8443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pks-api-8443.arn
  }
}

resource "aws_lb_target_group" "pks-api-8443" {
  name     = "${var.environment_name}-pks-tg-8443"
  port     = 8443
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id
}

###
# dev-01 k8s cluster NLB
###
resource "aws_lb" "k8s-dev-01" {
  name                             = "${var.environment_name}-k8s-dev-01"
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  internal                         = false
  subnets                          = aws_subnet.public-subnet[*].id
}

resource "aws_lb_listener" "k8s-dev-01-8443" {
  load_balancer_arn = aws_lb.k8s-dev-01.arn
  port              = 8443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s-dev-01-8443.arn
  }
}

resource "aws_lb_target_group" "k8s-dev-01-8443" {
  name     = "${var.environment_name}-k8s-dev-01-tg-8443"
  port     = 8443
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = 6
    unhealthy_threshold = 6
    interval            = 10
    protocol            = "TCP"
  }
}
