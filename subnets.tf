
#
# Public Subnet
# This is where Opsman, the Bosh Director, and the PKS API server will live
#
resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  # With 'k8s_uuids', we merge in the UUIDs from the file 'terraform.tfvars'.
  tags = merge(
    var.tags,
    var.k8s_uuids,
    { Name = "${var.environment_name}-public-subnet-${count.index}"},
  )
}

#
# Private 'pks' subnet. This is where our workload k8s clusters will live.
#
resource "aws_subnet" "pks-subnet" {
  count = length(var.pks_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.pks_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.tags,
    { Name = "${var.environment_name}-pks-subnet-${count.index}" },
  )
}
