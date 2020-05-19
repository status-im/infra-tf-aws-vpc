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
    - `zones` - Listo of Availability Zones for VPCs and Subnets (Default: `["eu-central-1a", ...]`)
    - `vpc_cidr_block` - Classless Inter-Domain Routing address space. (Default: `172.20.0.0/16`)
    - `subnet_cidr_blocks` - List of subnets of the VPC CIDR block address space. (Default: `["172.20.1.0/24", ...]`)
* __Firewall__
    - `open_tcp_ports` - List of TCP port ranges to open.
    - `open_udp_ports` - List of UDP port ranges to open.

# Outputs

* `vpc` - The VPC resoruce
* `subnets` - List of Subnet resources
* `secgroup` - The Security Group resource
