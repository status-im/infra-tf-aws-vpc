# Description

This defines a [Terraform](https://www.terraform.io/) module that configures an AWS VPC.

# Usage

```tf
module "my_network" {
  source = "github.com/status-im/infra-tf-aws-vpc"

  name  = "myfleet"
  stage = "prod"

  /* Firewall */
  open_udp_ports = [ "53", "1234" ]
  open_tcp_ports = [ "22", "80", "443" ]
}
```

# Variables

Here are the variables available in the module:

* __General__
    - `name` - Name to use for VPC elements
    - `stage` - Stage to use for VPC elements
* __Plumbing__
    - `zone` - Availability Zone for VPCs and Subnets
    - `vpc_cidr_block` - IPv4 address space from Classless Inter-Domain Routing for VPC.
    - `subnet_cidr_block` - Subnet of the VPC CIDR block address space.
* __Firewall__
    - `open_tcp_ports` - List of TCP port ranges to open.
    - `open_udp_ports` - List of UDP port ranges to open.
