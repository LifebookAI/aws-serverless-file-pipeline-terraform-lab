variable "aws_profile" {
  description = "AWS CLI profile used by Terraform for local deployments."
  type        = string
  default     = "lifebook-sso"
}

variable "aws_region" {
  description = "AWS region where lab resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used for naming AWS resources."
  type        = string
  default     = "serverless-file-pipeline-tf"
}

variable "environment" {
  description = "Environment name for tagging and naming."
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address for SNS alert notifications. Set locally in terraform.tfvars; do not commit real personal emails."
  type        = string
  default     = ""
}