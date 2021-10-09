### VPC Variables ###
variable "aws_vpc_name" {
  default = "ao-tech-test"
}

variable "aws_azs" {
  description = "comma separated string of availability zones in order of precedence"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "vpc_cidr_base" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "comma separated string of private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnets" {
  description = "comma separated string of public subnets"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

### Global Variables ###
variable "global_tags" {
  description = "AWS tags that will be added to all resources managed herein"
  type        = map(string)
  default = {
    "Author"     = "Sohail Pervaiz"
    "Managed By" = "Terraform"
  }
}
