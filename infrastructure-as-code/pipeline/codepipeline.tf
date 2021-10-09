#########################
### Codepipeline role ###
#########################
resource "aws_iam_role" "codepipeline_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}

###########################
### Codepipeline policy ###
###########################
resource "aws_iam_policy" "codepipeline_policy" {
  description = "Policy to allow codepipeline to execute"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.artifact_bucket.arn}/*"
    },
    {
      "Action" : [
        "codebuild:StartBuild", "codebuild:BatchGetBuilds",
        "cloudformation:*",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action" : [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

######################################
### Codepipeline policy attachment ###
######################################
resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

##############################
### Codepipeline s3 bucket ###
##############################
resource "aws_s3_bucket" "artifact_bucket" {
}

####################
### Codepipeline ###
####################
resource "aws_codepipeline" "pipeline" {
  depends_on = [
    aws_codebuild_project.codebuild_project
  ]
  name     = "ao-tech-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      version          = "1"
      provider         = "GitHub"
      output_artifacts = ["SourceOutput"]
      run_order        = 1
      configuration = {
        "Branch"               = var.github_branch
        "Owner"                = var.github_owner
        "PollForSourceChanges" = "false"
        "Repo"                 = var.github_repo
        "OAuthToken"           = var.github_outh_token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.id
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      version         = "1"
      provider        = "ECS"
      run_order       = 1
      input_artifacts = ["BuildOutput"]
      configuration = {
        ClusterName       = var.ecs_cluster_name
        ServiceName       = var.ecs_cluster_fargate_service_name
        FileName          = "imagedefinitions.json"
        DeploymentTimeout = "15"
      }
    }
  }
}


###################################
### Codepipeline Github webhook ###
###################################
resource "aws_codepipeline_webhook" "codepipeline_webhook" {
  authentication  = "GITHUB_HMAC"
  name            = "codepipeline-webhook"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pipeline.name

  authentication_configuration {
    secret_token = random_string.github_secret.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
  tags = {}
}

resource "random_string" "github_secret" {
  length  = 99
  special = false
}
