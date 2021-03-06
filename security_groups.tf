
#
# We're not necessarily deploying TAS but we still need this security group
# for the Bosh director.
#
resource "aws_security_group" "platform" {
  name   = "${var.environment_name}-platform-vms-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  # To allow kubectl to interact with k8s masters
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8443
    protocol = "tcp"
    to_port = 8443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-platform-vms-sg" },
  )
}
#
# NAT instances/gateways
#
resource "aws_security_group" "nat" {
  name   = "${var.environment_name}-nat-sg"
  vpc_id = aws_vpc.vpc.id

  # All traffic from within the VPC
  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  # All traffic coming from the VPC
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-nat-sg" },
  )
}

#
# Ops Manager
#
resource "aws_security_group" "ops-manager" {
  name   = "${var.environment_name}-ops-manager-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol = "tcp"
    from_port = 25555
    to_port = 25555
  }

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol = "tcp"
    from_port = 6868
    to_port = 6868
  }

  ingress {
    cidr_blocks = var.ops_manager_allowed_ips
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
  }

  ingress {
    cidr_blocks = var.ops_manager_allowed_ips
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }

  ingress {
    cidr_blocks = var.ops_manager_allowed_ips
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-ops-manager-sg" },
  )
}

#
# k8s workloads
#
resource "aws_security_group" "pks-internal-sg" {
  name        = "${var.environment_name}-pks-internal"
  description = "PKS Internal Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    cidr_blocks = var.pks_subnet_cidrs
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
  }

  ingress {
    cidr_blocks = var.pks_subnet_cidrs
    protocol    = "tcp"
    from_port   = 0
    to_port     = 0
  }

  ingress {
    cidr_blocks = var.pks_subnet_cidrs
    protocol    = "udp"
    from_port   = 0
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-pks-internal" },
  )
}

#
# PKS API server
#
resource "aws_security_group" "pks-api-lb" {
  name        = "${var.environment_name}-pks-api-lb-sg"
  description = "PKS API LB Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 9021
    to_port     = 9021
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 8443
    to_port     = 8443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-pks-api-lb-sg" },
  )
}

#
# Security Group for:
# - Bosh Director
# - PKS API Server
# - k8s master nodes
# - k8s worker nodes
#
# Why? Because the security group ID we specify in the Bosh Director config tile in Ops Man
# is the same security group ID that is used when we deploy all the other VMs. The only way
# around this is to use VM extensions, which have two problems:
# 1) They complicate operations because they're only configurable in yaml files (i.e. not via Ops Man)
# 2) Even with a VM extension, you can only change the security group for the PKS API server. You cannot
#    change the security group for the k8s master or workers.
# Therefore, we avoid complexity by just having an overloaded security group.
resource "aws_security_group" "pks-umbrella-sg" {
  name        = "${var.environment_name}-pks-umbrella-sg"
  description = "Secgroup for pks-api, k8s clusters, and Bosh Director"
  vpc_id      = aws_vpc.vpc.id

  #
  # Bosh Director
  #
  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  #
  # PKS API
  #
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 9021
    to_port     = 9021
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 8443
    to_port     = 8443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  #
  # Internal k8s cluster traffic
  #
  ingress {
    cidr_blocks = var.pks_subnet_cidrs
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
  }

  ingress {
    cidr_blocks = var.pks_subnet_cidrs
    protocol    = "tcp"
    from_port   = 0
    to_port     = 0
  }

  ingress {
    cidr_blocks = var.pks_subnet_cidrs
    protocol    = "udp"
    from_port   = 0
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }


  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-pks-umbrella-sg" },
  )
}
