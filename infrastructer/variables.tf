variable "aws_region" {
  default = "ap-southeast-2"
}

variable "environment" {
  default = "dev"
  type    = string
}

variable "project_name" {
  description = "Used to prefix all resources names"
  type        = string
  default     = "voting-app"
}

variable "cidr" {
  default = "10.0.0.0/16"
}
