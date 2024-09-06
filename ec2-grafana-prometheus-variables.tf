variable "aws_region" {
  description = "The AWS region where resources will be created."
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key."
}

variable "aws_secret_key" {
  description = "AWS secret key."
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID."
}

variable "key_name" {
  description = "The name of the SSH key pair."
}

variable "public_key_path" {
  description = "Path to the SSH public key file."
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to the SSH private key file for the key pair."
  default     = "~/.ssh/id_rsa"
}
