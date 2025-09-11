# Домашнє завдання до теми «Вивчення Agro CD + CD»

## Кроки виконання завдання

1. Jenkins + Helm + Terraform

- Встановіть Jenkins через Helm, автоматизувавши встановлення через Terraform.
- Забезпечте роботу Jenkins через Kubernetes Agent (Kaniko + Git).
- Реалізуйте pipeline (через Jenkinsfile), який:
- Збирає образ із Dockerfile;
- Пушить його до ECR;
- Оновлює тег у values.yaml іншого репозиторію;
- Пушить зміни в main.

2. Argo CD + Helm + Terraform

- Встановіть Argo CD через Helm із використанням Terraform.
- Налаштуйте Argo CD Application, який стежить за оновленням Helm-чарта.
- Argo CD має автоматично синхронізувати зміни у кластері після оновлення Git.


## Налаштування змінних
Створіть файл `terraform.tfvars` з наступними змінними:

```
github_token  = <your github token>
github_username  = <your github username>
github_repo_url = "https://github.com/<repo>.git"
```

Можете використати `terraform.tfvars.example` як приклад.

## Команди для ініціалізації, запуску та видалення

```bash
# Ініціалізація
terraform init

# Перегляд змін інфраструктури
terraform plan

# Застосування інфраструктури
terraform apply

# Видалення інфраструктури
terraform destroy
```

## Налаштування kubectl

```bash
# Підключення до EKS-кластеру
aws eks update-kubeconfig --region us-west-2 --name [EKS_CLUSTER_NAME]

# Перевірка доступу
kubectl get nodes
```

## Завантаження Docker-образу на новостворений ECR-репозиторій

```bash
# Перехід у папку з Django-проєктом
cd docker/django

# Збірка образу без кешу
docker build --no-cache -t django-app .

# Логін у ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [ACCOUNT_ID].dkr.ecr.us-west-2.amazonaws.com

# Тегування
docker tag django-app:latest [ACCOUNT_ID].dkr.ecr.us-west-2.amazonaws.com/django-app:latest

# Завантаження
docker push [ACCOUNT_ID].dkr.ecr.us-west-2.amazonaws.com/django-app:latest

# Повернення до кореневої директорії проєкту
cd ../..
```

## Застосування Helm:

```bash
cd charts/django-app
helm install django-app .
```

where `django-app` is your helm chart name.

## Видалення ресурсів:

Kubernetes (PODs, Services, Deployments etc.)
```bash
helm uninstall django-app
```

where `django-app` is your helm chart name.

Terraform (EKS, VPC, ECR etc.)

```bash
terraform destroy
```

## Додаткова інформація:

Якщо ви хочете оновити helm chart:

```bash
helm upgrade django-app .
```

Якщо ви хочете оновити terraform:

```bash
terraform init -upgrade
terraform plan
terraform apply
```

### Доступ до Jenkins

```bash
# Jenkins URL
kubectl get services -n jenkins

# Отримати початковий пароль Jenkins
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# Чи вже налаштований пароль: admin123
```

### Доступ до Argo CD
```
# Отримати Argo CD URL
kubectl get services -n argocd

# Отримати початковий пароль для admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Налаштування віддаленого бекенду

Після початкового розгортання для активації віддаленого бекенду:

1. Розкоментуйте блок конфігурації бекенду в `backend.tf`.

2. Виконайте команду `terraform init` з параметром для повторного підключення бекенду:

```bash
terraform init -reconfigure
```

### Відновлення
1. Закоментуйте конфігурацію бекенду в `backend.tf`.
2. Виконайте `terraform init`.
3. Застосуйте конфігурацію `terraform apply`.
4. Розкоментуйте бекенд та виконайте `terraform init -reconfigure`.
---