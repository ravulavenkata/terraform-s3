module "s3" {
  source = "../modules/s3"
  ENV = "dev"
  AWS_REGION = "${var.AWS_REGION}"
  AWS_BACKUP_REGION = "${var.AWS_BACKUP_REGION}"
}