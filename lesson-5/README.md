###Lesson-5 — Terraform (S3 Backend + DynamoDB Locks, VPC, ECR)

Інфраструктура на AWS us-west-2 (Oregon).
Стейт зберігається у S3 з DynamoDB для блокувань.

S3 bucket (для стейту): clp-tfstate-938094936571-dev

DynamoDB table (локи): terraform-locks

VPC: lesson-5-vpc (CIDR 10.0.0.0/16, 3 public + 3 private)

ECR: lesson-5-ecr (Scan on push: Enabled)

⚠️ NAT Gateway платний. Після перевірки ДЗ виконайте terraform destroy.

Вимоги

Terraform ≥ 1.6

AWS CLI налаштований на акаунт з регіоном us-west-2

PowerShell (команди нижче наведені для PowerShell)

Перевірка:

terraform -version
aws --version
aws sts get-caller-identity

Структура
lesson-5/
├── backend.tf
├── variables.tf
├── outputs.tf
└── modules/
    ├── s3-backend/
    │   ├── s3.tf
    │   ├── dynamodb.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── vpc/
    │   ├── vpc.tf
    │   ├── routes.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecr/
        ├── ecr.tf
        ├── variables.tf
        └── outputs.tf

Порядок запуску (бутстрап → міграція бекенду → повний apply)

У Terraform є «курка-яйце»: щоб зберігати стейт у S3, треба спочатку створити S3 та DynamoDB. Тому перший apply робимо локальним стейтом, далі мігруємо в S3.

1) Початковий запуск (локальний стейт)
cd lesson-5
terraform fmt -recursive
terraform init
terraform validate
# за потреби — тільки бекенд-ресурси (щоб швидше):
# terraform plan -target=module.s3_backend -out tf.plan
# terraform apply tf.plan
# або повний план:
terraform plan -out tf.plan
terraform apply tf.plan

2) Увімкнути віддалений бекенд (S3) та мігрувати стейт

Переконайтеся, що backend.tf містить саме ці значення:

terraform {
  backend "s3" {
    bucket         = "clp-tfstate-938094936571-dev"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


Міграція:

terraform init -migrate-state

3) Повторна перевірка/дотяжки
terraform plan
terraform apply
terraform output

Очікувані виводи (приклад)
dynamodb_table_name = "terraform-locks"
ecr_repository_url  = "938094936571.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr"
public_subnet_ids   = ["subnet-…", "subnet-…", "subnet-…"]
private_subnet_ids  = ["subnet-…", "subnet-…", "subnet-…"]
s3_bucket_name      = "clp-tfstate-938094936571-dev"
vpc_id              = "vpc-…"

Перевірка в AWS Console

S3 → Buckets → clp-tfstate-938094936571-dev

є lesson-5/terraform.tfstate

Versioning: Enabled, Block public access: On

DynamoDB → Tables → terraform-locks

під час plan/apply створюється запис LockID (блокування)

VPC → lesson-5-vpc

6 підмереж (3 public, 3 private) у us-west-2a/b/c

IGW прив’язаний до VPC, 1 NAT Gateway у public-сабнеті

Route Tables: *-rt-public з 0.0.0.0/0 через IGW; *-rt-private через NAT

ECR → lesson-5-ecr

Scan on push: Enabled

Repository policy: доступ для arn:aws:iam::<account-id>:root

Типові команди
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
terraform state list
terraform output
terraform destroy

Якщо ресурси вже існували (імпорт у стейт)

При помилках виду AlreadyExists / ResourceInUse:

# Імпорт DynamoDB таблиці локів
terraform import module.s3_backend.aws_dynamodb_table.tf_locks terraform-locks

# Імпорт ECR репозиторію
terraform import module.ecr.aws_ecr_repository.repo lesson-5-ecr


Після імпорту — terraform plan → terraform apply.

Вартість та чистка

NAT Gateway — платний погодинно.

Після перевірки домашнього завдання:

cd lesson-5
terraform destroy