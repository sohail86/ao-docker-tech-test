###############################################
## Create a base network/VPC for infrastructure
###############################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.aws_vpc_name
  cidr = var.vpc_cidr_base

  azs             = var.aws_azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = var.global_tags
}

#########################################
## Create a security group for web server
#########################################
module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name                = "web-server"
  description         = "Allow Access to Web Port from anywhere"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = var.global_tags
}

#########################
## Create a load balancer
#########################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name               = "ao-tech-test-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.web_server_sg.security_group_id, module.vpc.default_security_group_id]

  tags = var.global_tags
}

########################
## Create a ecs cluster
########################
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name               = "ao-tech-test-ecs"
  container_insights = true
  capacity_providers = ["FARGATE"]

  tags = var.global_tags
}

##########################
## Create a ecr repository
##########################
resource "aws_ecr_repository" "ao-web-ecr" {
  name                 = "ao-tech-test-ecr"
  image_tag_mutability = "MUTABLE"
}

#########################################
## Create a fargate service for web app
#########################################
module "ecs-fargate" {
  source  = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix                     = "ao-tech-test-fargate"
  vpc_id                          = module.vpc.vpc_id
  private_subnet_ids              = module.vpc.private_subnets
  cluster_id                      = module.ecs.ecs_cluster_id
  task_container_image            = "${aws_ecr_repository.ao-web-ecr.repository_url}:latest"
  task_definition_cpu             = 256
  task_definition_memory          = 512
  task_container_port             = 80
  task_container_assign_public_ip = true

  target_groups = [
    {
      target_group_name = "tg-ao-tech-test"
      container_port    = 80
    }
  ]

  health_check = {
    port = "traffic-port"
    path = "/"
  }

  tags = var.global_tags
}

resource "aws_lb_listener" "alb_80" {
  load_balancer_arn = module.alb.lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.ecs-fargate.target_group_arn[0]
  }
}

resource "aws_security_group_rule" "task_ingress_80" {
  security_group_id        = module.ecs-fargate.service_sg_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = module.web_server_sg.security_group_id
}

#######################################
## Create a pipeline for the project
#######################################
module "pipeline" {
  source = "./pipeline"

  aws_account_id = data.aws_caller_identity.current.account_id

  ecr_image_uri = aws_ecr_repository.ao-web-ecr.repository_url
  ecs_cluster_fargate_service_name = module.ecs-fargate.service_name
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecr_image_name = aws_ecr_repository.ao-web-ecr.name

  github_branch = "master"
  github_outh_token = "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"
  github_owner = "sohail86"
  github_repo = "ao-docker-tech-test"

}

#######################################
## Create a pipeline for the project
#######################################
output "alb_dns" {
  value = module.alb.lb_dns_name
}
