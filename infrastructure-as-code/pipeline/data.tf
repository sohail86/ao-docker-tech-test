###### Build-Spec file for CodeBuild ######
data "template_file" "buildspec" {
  template = file("./pipeline/buildspec.yml")
  vars = {
    IMAGE_URI      = "${var.ecr_image_uri}:latest"
    CONTAINER_NAME = "ao-tech-test-fargate"
  }
}
