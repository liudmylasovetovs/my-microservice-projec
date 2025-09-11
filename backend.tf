# Розкоментуйте, щоб підключити бекенд до Terraform

# terraform {
#   backend "s3" {
#     bucket         = "clp-tfstate-938094936571-dev"               # Назва S3-бакета
#     key            = "lesson-8-9/terraform.tfstate"               # Шлях до файлу стейту
#     region         = "us-west-2"                                  # Регіон AWS
#     dynamodb_table = "terraform-locks"                            # Назва таблиці DynamoDB
#     encrypt        = true                                         # Шифрування файлу стейту
#   }
# }
