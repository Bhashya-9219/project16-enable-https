variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-03389c41f719f68ac"
}

variable "subnet_a" {
  type    = string
  default = "subnet-02a246541c0a65ad4"
}

variable "subnet_b" {
  type    = string
  default = "subnet-0aa0b0134e8785375"
}
variable "certificate_arn" {
  description = "ACM certificate ARN for Project 16 HTTPS"
  type        = string
  default     = "arn:aws:acm:ap-south-1:590507089733:certificate/5a67f455-99b5-4492-b27b-cafa2ca74c24"
}
