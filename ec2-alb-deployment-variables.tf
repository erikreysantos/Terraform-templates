variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

variable "public_subnets" {
  description = "Public subnets for the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
}

variable "aws_access_key" {
  description = "The ID of the VPC where resources will be created"
}

variable "aws_secret_key" {
  description = "The ID of the VPC where resources will be created"
}
