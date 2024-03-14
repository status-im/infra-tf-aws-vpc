/* The VPN allows us to limit certain traffic to just local network */
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "vpc-${var.name}-${var.stage}"
  }
}

/* A VPN can't exist by itself, a subnet is necessary to add instances */
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_blocks[count.index % length(var.subnet_cidr_blocks)]

  /* Each AZ needs its own subnet */
  count = length(var.zones)

  /* Needs to be the same as the instances zone */
  availability_zone = element(var.zones, count.index % length(var.zones))

  /* Necessary for instances available publicly */
  map_public_ip_on_launch = true
  /* Enable IPv6 addresses for new instances. */
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0) # /64 bit subnet

  tags = {
    Name = "sn-${var.name}-${var.stage}"
  }
}

/* Necessary for internet access */
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-${var.name}-${var.stage}"
  }
}

/* Adds rule for accessing internet via the Gateway */
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  /* Allow internet traffic in */
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt-${var.name}-${var.stage}"
  }
}

/* Add the route to Gateway to the Subnet */
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
  count          = length(var.zones)
}

/* Open the necessary ports to the outside */
resource "aws_security_group" "main" {
  name        = "${var.name}-${var.stage}"
  description = "Allow inbound traffic for Nimbus fleet"
  vpc_id      = aws_vpc.main.id

  /* Allow local incoming traffic, necessary for logging */
  ingress {
    from_port = 0
    to_port   = 0
    self      = true
    protocol  = "-1"
  }

  /* Allowing ALL outgoing */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  /* TCP */
  dynamic "ingress" {
    iterator = port
    for_each = var.open_tcp_ports
    content {
      /* Hacky way to handle ranges as strings */
      from_port = tonumber(
        length(split("-", port.value)) > 1 ? split("-", port.value)[0] : port.value
      )
      to_port = tonumber(
        length(split("-", port.value)) > 1 ? split("-", port.value)[1] : port.value
      )
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  /* UDP */
  dynamic "ingress" {
    iterator = port
    for_each = var.open_udp_ports
    content {
      /* Hacky way to handle ranges as strings */
      from_port = tonumber(
        length(split("-", port.value)) > 1 ? split("-", port.value)[0] : port.value
      )
      to_port = tonumber(
        length(split("-", port.value)) > 1 ? split("-", port.value)[1] : port.value
      )
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  /* Without this aws_route_table is not created in time */
  depends_on = [
    aws_route_table_association.main
  ]
}
