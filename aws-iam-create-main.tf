provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create IAM User
resource "aws_iam_user" "iam_user" {
  name = var.iam_user_name
  tags = {
    "Name" = "new created user"
  }
}

# Attach Administrator Access Policy to the IAM User
resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Optionally create an Access Key for programmatic access
resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

# Output the Access Key ID and Secret Access Key (Sensitive Information)
output "access_key_id" {
  value = aws_iam_access_key.iam_access_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.iam_access_key.secret
  sensitive = true
}

# Create a one-time login profile for the IAM user
resource "aws_iam_user_login_profile" "example_login_profile" {
  user = aws_iam_user.example_user.name

  password_reset_required = true  # Require password change on first login
  password = var.initial_password  # One-time password
}
