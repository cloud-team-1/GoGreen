
# for the purpose fo creating local code, added a VPC data:

#data "aws_vpc" "current-vpc" {
#  id = var.vpc_id
#}

  resource "aws_network_acl" "app-tier-nacl" {
    vpc_id = "${module.vpc.vpc-id}"
    subnet_ids = "${module.vpc.private-subnet-ids}"

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 3306
    to_port    = 3306
  }

    ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 22
    to_port    = 22
  }

    ingress {
    protocol   = "icmp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

    ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }
  tags = {
    Name = "app-tier-acl"
  }
}

