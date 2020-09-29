# Web Load Balancer

###
# PKS API Load Balancer
# i.e. 'pks-api.domain.com'
# We use a Network Load Balancer (NLB) instead of a Classical ELB
# A successful NLB is three parts:
# - The NLB itself
# - A Listener for each port
# - A Target Group for each Listener
###
resource "aws_lb" "pks-api" {
  name                             = "${var.environment_name}-pks-api"
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  internal                         = false
  subnets                          = aws_subnet.public-subnet[*].id
}

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

###########
# Example #
###################################################################################################################
# When you create a workload k8s cluster, you need to expose the k8s master(s) on port 8443. In this instance,    #
# we create another NLB, just as we did for the PKS API server.                                                   #
# NOTE: This must be done for *each* k8s cluster deployed.                                                        #
# Uncomment and update the resources below to create an NLB for one k8s cluster.                                  #
###################################################################################################################

#resource "aws_lb" "k8s-dev-01" {
#  name                             = "${var.environment_name}-k8s-dev-01"
#  load_balancer_type               = "network"
#  enable_cross_zone_load_balancing = true
#  internal                         = false
#  subnets                          = aws_subnet.public-subnet[*].id
#}
#
#resource "aws_lb_listener" "k8s-dev-01-8443" {
#  load_balancer_arn = aws_lb.k8s-dev-01.arn
#  port              = 8443
#  protocol          = "TCP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.k8s-dev-01-8443.arn
#  }
#}
#
#resource "aws_lb_target_group" "k8s-dev-01-8443" {
#  name     = "${var.environment_name}-k8s-dev-01-tg-8443"
#  port     = 8443
#  protocol = "TCP"
#  vpc_id   = aws_vpc.vpc.id
#
#  health_check {
#    healthy_threshold   = 6
#    unhealthy_threshold = 6
#    interval            = 10
#    protocol            = "TCP"
#  }
#}

###########
# Example #
###############################################################################################################
# Manually creating an NLB for each k8s cluster becomes cumbersome. Using the below resources, we             #
# create an NLB (and the Listener and the Target Group) for every k8s cluster that appears in the             #
# variable 'k8s_clusters' in the file 'terraform.tfvars'.                                                        #
# To use the resources defined below, simply add the UUID for your k8s cluster to the 'k8s_uuids' variable    #
# and re-run Terraform.                                                                                       #
# NOTE: You still need to add the k8s master(s) to the Target Group yourself                                  #
###############################################################################################################
#resource "aws_lb" "k8s-workload-cluster-nlb" {
#  for_each = var.k8s_clusters
#  name                             = "${each.key}-k8s-nlb"
#  load_balancer_type               = "network"
#  enable_cross_zone_load_balancing = true
#  internal                         = false
#  subnets                          = aws_subnet.public-subnet[*].id
#}
#
#resource "aws_lb_listener" "k8s-workload-cluster-8443" {
#  for_each = var.k8s_clusters
#  load_balancer_arn = aws_lb.k8s-workload-cluster-nlb[each.key].arn
#  port              = 8443
#  protocol          = "TCP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.k8s-workload-cluster-8443[each.key].arn
#  }
#}
#
#resource "aws_lb_target_group" "k8s-workload-cluster-8443" {
#  for_each = var.k8s_clusters
#  name     = "${var.environment_name}-${each.key}-k8s-tg"
#  port     = 8443
#  protocol = "TCP"
#  vpc_id   = aws_vpc.vpc.id
#
#  health_check {
#    healthy_threshold   = 6
#    unhealthy_threshold = 6
#    interval            = 10
#    protocol            = "TCP"
#  }
#}



