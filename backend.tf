terraform {
  backend "s3" {
    bucket       = "lifebookai-tfstate-354630286254-us-east-1"
    key          = "aws-serverless-file-pipeline-terraform-lab/dev/terraform.tfstate"
    region       = "us-east-1"
    profile      = "lifebook-sso"
    encrypt      = true
    use_lockfile = true
  }
}
