# Домашнє завдання: Створення гнучкого Terraform-модуля для баз даних

## Функціонал модуля:

- `use_aurora` = `true` → створюється Aurora Cluster + writer;
- `use_aurora` = `false` → створюється одна `aws_db_instance`;
- В обох випадках:
  - створюється `aws_db_subnet_group`;
  - створюється `aws_security_group`;
  - створюється `parameter group` з базовими параметрами (`max_connections`, `log_statement`, `work_mem`);
  - Параметри `engine`, `engine_version`, `instance_class`, `multi_az` задаються через змінні.

## Налаштування змінних
У корні проєкту створіть файл `terraform.tfvars` з наступними змінними:

```
github_token  = <github_token>
github_username  = <github_username>
github_repo_url = "https://github.com/<repo>.git"

rds_password = <rds_password>
rds_username = <rds_username>
rds_database_name = <rds_database_name>
rds_publicly_accessible = true

# true → створюється Aurora Cluster + writer
# false → створюється одна aws_db_instance
rds_use_aurora = true

rds_multi_az = false
rds_backup_retention_period = "0"
```

Або можете використати `terraform.tfvars.example` як приклад.

## Налаштування середовища
`region` за замовченням `us-east-1`

```
terraform init
terraform plan
terraform apply
```

## Налаштування kubectl

```bash
# Підключення до EKS-кластеру
aws eks update-kubeconfig --region us-west-2 --name <your_cluster_name>

# Перевірка доступу
kubectl get nodes

# або перевірка сервісів в кластері:
kubectl get svc -A
```
![bash](./assets/bash.png)
![jenkins](./assets/jenkins.png)

## Видалення ресурсів
```bash
terraform destroy
```

## Налаштування віддаленого бекенду

Після початкового розгортання для активації віддаленого бекенду:

1. Розкоментуйте блок конфігурації бекенду в `backend.tf`.

2. Виконайте команду `terraform init` з параметром для повторного підключення бекенду:

```bash
terraform init -reconfigure
```

## Відновлення
1. Закоментуйте конфігурацію бекенду в `backend.tf`.
2. Виконайте `terraform init`.
3. Застосуйте конфігурацію `terraform apply`.
4. Розкоментуйте бекенд та виконайте `terraform init -reconfigure`.
