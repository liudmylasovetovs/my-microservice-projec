# Покрокова інструкція виконання фінального проєкту

## Опис завдання
Технічні вимоги:

 1. Інфраструктура: AWS з використанням Terraform
 2. Компоненти: VPC, EKS, RDS, ECR, Jenkins, Argo CD, Prometheus, Grafana

---

## Структура проєкту

```
Project/
│
├── main.tf         # Головний файл для підключення модулів
├── backend.tf        # Налаштування бекенду для стейтів (S3 + DynamoDB
├── outputs.tf        # Загальні виводи ресурсів
│
├── modules/         # Каталог з усіма модулями
│  ├── s3-backend/     # Модуль для S3 та DynamoDB
│  │  ├── s3.tf      # Створення S3-бакета
│  │  ├── dynamodb.tf   # Створення DynamoDB
│  │  ├── variables.tf   # Змінні для S3
│  │  └── outputs.tf    # Виведення інформації про S3 та DynamoDB
│  │
│  ├── vpc/         # Модуль для VPC
│  │  ├── vpc.tf      # Створення VPC, підмереж, Internet Gateway
│  │  ├── routes.tf    # Налаштування маршрутизації
│  │  ├── variables.tf   # Змінні для VPC
│  │  └── outputs.tf  
│  ├── ecr/         # Модуль для ECR
│  │  ├── ecr.tf      # Створення ECR репозиторію
│  │  ├── variables.tf   # Змінні для ECR
│  │  └── outputs.tf    # Виведення URL репозиторію
│  │
│  ├── eks/           # Модуль для Kubernetes кластера
│  │  ├── eks.tf        # Створення кластера
│  │  ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│  │  ├── variables.tf   # Змінні для EKS
│  │  └── outputs.tf    # Виведення інформації про кластер
│  │
│  ├── rds/         # Модуль для RDS
│  │  ├── rds.tf      # Створення RDS бази даних  
│  │  ├── aurora.tf    # Створення aurora кластера бази даних  
│  │  ├── shared.tf    # Спільні ресурси  
│  │  ├── variables.tf   # Змінні (ресурси, креденшели, values)
│  │  └── outputs.tf  
│  │ 
│  ├── jenkins/       # Модуль для Helm-установки Jenkins
│  │  ├── jenkins.tf    # Helm release для Jenkins
│  │  ├── variables.tf   # Змінні (ресурси, креденшели, values)
│  │  ├── providers.tf   # Оголошення провайдерів
│  │  ├── values.yaml   # Конфігурація jenkins
│  │  └── outputs.tf    # Виводи (URL, пароль адміністратора)
│  │ 
│  └── argo_cd/       # ✅ Новий модуль для Helm-установки Argo CD
│    ├── jenkins.tf    # Helm release для Jenkins
│    ├── variables.tf   # Змінні (версія чарта, namespace, repo URL тощо)
│    ├── providers.tf   # Kubernetes+Helm. переносимо з модуля jenkins
│    ├── values.yaml   # Кастомна конфігурація Argo CD
│    ├── outputs.tf    # Виводи (hostname, initial admin password)
│		  └──charts/         # Helm-чарт для створення app'ів
│ 	 	  ├── Chart.yaml
│	 	  ├── values.yaml     # Список applications, repositories
│			  └── templates/
│		    ├── application.yaml
│		    └── repository.yaml
├── charts/
│  └── django-app/
│    ├── templates/
│    │  ├── deployment.yaml
│    │  ├── service.yaml
│    │  ├── configmap.yaml
│    │  └── hpa.yaml
│    ├── Chart.yaml
│    └── values.yaml   # ConfigMap зі змінними середовища
└──Django
			 ├── app\
			 ├── Dockerfile
			 ├── Jenkinsfile
			 └── docker-compose.yaml

```
# Етапи виконання

## Підготовка середовища:

Ініціалізувати Terraform.
Перевірити всі необхідні змінні та параметри.

    github_pat  = <github token>
    github_user  = <github username>
    github_repo_url = "https://github.com/<repo>.git"
    github_branch = "main"

    rds_password = <rds_password>
    rds_username = <rds_username>
    rds_database_name = <rds_database_name>
    rds_publicly_accessible = true

    # true → створюється Aurora Cluster + writer
    # false → створюється одна aws_db_instance
    rds_use_aurora = true
    rds_multi_az = false
    rds_backup_retention_period = "0"

## Розгортання інфраструктури:

region за замовченням us-west-2

```bash

terraform init
terraform plan
terraform apply

```

## Налаштування kubectl

```bash

aws eks update-kubeconfig --region us-west-2 --name <your_cluster_name>

kubectl get nodes

kubectl get svc -A

```

Відкрийте Jenkins LoadBalancer URL (username: admin; password: admin123)

запустіть seed-job задачу (це створить нову задачу django-docker)
запустіть django-docker задачу:
  Збере та завантажить образ Docker до ECR
  Об'єднає MR у вашому репозиторії з оновленням версії програми (відповідно до номера збірки завдання Jenkins django-docker)

## Перевірка доступності:

  Jenkins:

```bash

kubectl port-forward svc/jenkins 8080:8080 -n jenkins

```

  Argo CD:

```bash

kubectl port-forward svc/argocd-server 8081:443 -n argocd

```

## Моніторинг та перевірка метрик:

  Grafana:

```bash

kubectl port-forward svc/grafana 3000:80 -n monitoring

```

  відкрити http://localhost:3000
  ввести імʼя користувача admin та пароль, використавши наступну команду kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
  Перевірити стан метрик в Grafana Dashboard.

## Видалення ресурсів

```bash

terraform destroy

```