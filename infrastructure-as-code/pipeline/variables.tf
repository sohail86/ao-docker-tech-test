variable "ecr_image_uri" {
  description = "ECR image URI"
  type        = string
}
variable "ecr_image_name" {
  description = "ECR image Name"
  type        = string
}
variable "aws_account_id" {
  description = "aws current account id"
  type        = string
}

### Git Hub ####
variable "github_repo" {
  description = "github repo name"
  type        = string
}
variable "github_owner" {
  description = "github repo owner"
  type        = string
}
variable "github_outh_token" {
  description = "github repo token"
  type        = string
}
variable "github_branch" {
  description = "github repo branch"
  type        = string
}

#### ECS #######
variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_cluster_fargate_service_name" {
  description = "ECS cluster fargate service name"
  type        = string
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
