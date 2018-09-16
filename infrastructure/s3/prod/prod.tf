module "s3" {
  source = "../modules/s3"
  ENV = "prod"
  AWS_REGION = "${var.AWS_REGION}"
}
