variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

# Назва бакета для стейту (унікальна в усьому S3).
variable "tf_state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform state"
  # Використовуємо унікальне ім'я з вашим Account ID:
  default = "clp-tfstate-938094936571-dev"
}
