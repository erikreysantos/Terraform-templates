variable "aws_region" {
  description = "The AWS region where the resources will be created"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key for authentication"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "The name tag for the EC2 instance"
  type        = string
}

variable "instance_name2" {
  description = "The name tag for the EC2 instance"
  type        = string
}
