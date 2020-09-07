module "vpc" {
  source = "./modules/vpc"

  ###VPC###
  instance-tenancy                   = "default"
  enable-dns-support                 = "true"
  enable-dns-hostnames               = "true"
  vpc-name                           = "Project-vpc"
  vpc-location                       = "California"
  region                             = "us-west-1"
  internet-gateway-name              = "Project-igw"
  map_public_ip_on_launch            = "true"
  public-subnets-name                = "public-subnets"
  public-subnets-location            = "California"
  public-subnet-routes-name          = "public-subnet-routes"
  private-subnets-location-name      = "California"
  private-subnet-name                = "private-subnets"
  total-nat-gateway-required         = "1"
  eip-for-nat-gateway-name           = "eip-nat-gateway"
  nat-gateway-name                   = "nat-gateway"
  private-route-cidr                 = "0.0.0.0/0"
  private-route-name                 = "private-route"
  vpc-cidr                           = "10.0.0.0/16"
  vpc-public-subnet-cidr             = ["10.0.1.0/24", "10.0.2.0/24"]
  vpc-private-subnet-cidr            = ["10.0.3.0/24", "10.0.4.0/24"]
  vpc-private-subnet-RDS-cidr        = ["10.0.5.0/24"]
}

