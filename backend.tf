# Розкоментуйте, щоб підключити бекенд до Terraform

#terraform {
#  backend "s3" {
#    bucket         = "clp-tfstate-938094936571-dev"           # Назва S3-бакета
#    key            = "terraform.tfstate"                      # Шлях до файлу стейту
#    region         = "us-west-2"                              # Регіон AWS
#    dynamodb_table = "use_lockfile"                           # Назва таблиці DynamoDB
#    encrypt        = true                                     # Шифрування файлу стейту
#  }
#}
