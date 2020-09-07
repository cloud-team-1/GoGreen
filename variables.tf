
# Amazon Linux 2 AMI 2.0.20200722.0 x86_64 HVM 8GB
variable "aws_amis" {
  default = "ami-05655c267c89566dd"
}

variable "key_name" {
  type        = string
  default     = "CA_key"
  description = "my key is N CA"

}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}

variable "alarms_sms" {
  description = "sms to use to send notifications"
  default     = "+12026300504"
}

#Note - terraform doesnt support email as SNS requires validation
################ please erase below, another option for local email sns set up #######

#variable "sns_subscription_email_address_list" {
#type = string
# description = "List of email addresses as string(space separated)"
#  default = "rpaskalev@premieraquatics.com"
#}

# subnets to be uesed in web tier, provide by Farruh

# for the purpose of validating NACLs, added VPC variable:

#variable "web-sg-id" {
 # description = "id of the security group for the web tier instances"
  #default     = "${aws_security_group.web-tier-sg.id}"
