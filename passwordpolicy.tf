
terraform {
  required_version = ">= 0.12"
}

variable "allow_users_to_change_password" {
  type        = bool
  default     = true
  description = "Whether to allow users to change their own password"
}

variable "hard_expiry" {
  type        = string
  default     = false
  description = "Whether users are prevented from setting a new password after their password"
}

variable "max_password_age" {
  type        = number
  default     = 90
  description = "The number of days that an user password is valid."
}

variable "minimum_password_length" {
  type        = number
  default     = 8
  description = "Minimum length to require for user passwords."
}

variable "password_reuse_prevention" {
  type        = number
  default     = 3
  description = "The number of previous passwords that users are prevented from reusing."
}

variable "require_lowercase_characters" {
  type        = bool
  default     = true
  description = "Whether to require lowercase characters for user passwords."
}

variable "require_uppercase_characters" {
  type        = bool
  default     = true
  description = "Whether to require lowercase characters for user passwords."
}

variable "require_numbers" {
  type        = bool
  default     = true
  description = "Whether to require numbers for user passwords."
}

variable "require_symbols" {
  type        = bool
  default     = true
  description = "Whether to require symbols for user passwords."
}


resource "aws_iam_account_password_policy" "password_policy" {
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
  max_password_age               = var.max_password_age
  minimum_password_length        = var.minimum_password_length
  password_reuse_prevention      = var.password_reuse_prevention
  require_lowercase_characters   = var.require_lowercase_characters
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_symbols                = var.require_symbols
}



