# Lesson 7 — EKS + ECR + Helm (Django)

Регіон: **us-west-2**  
Акаунт AWS: **938094936571**  
Кластер: **lesson-6-eks**  
ECR репозиторій: **938094936571.dkr.ecr.us-west-2.amazonaws.com/lesson-6-django**  
Тег образу: **0.1.0**

---

## 1) Передумови

- Terraform ≥ 1.13
- AWS CLI 2.x (налаштований профіль із правами на EKS/ECR/IAM/EC2/S3)
- kubectl, Helm v3, Docker Desktop (Linux engine)
- У `backend.tf` використовується **S3 backend** із `use_lockfile = true` (без DynamoDB)

> Приклад `backend.tf`:
>
> ```hcl
> terraform {
>   backend "s3" {
>     bucket       = "clp-tfstate-938094936571-dev"
>     key          = "terraform.tfstate"
>     region       = "us-west-2"
>     encrypt      = true
>     use_lockfile = true
>   }
> }
> ```

> Якщо S3-бакета ще нема:
> ```powershell
> $REGION="us-west-2"; $ACCOUNT="938094936571"
> $BUCKET="clp-tfstate-$ACCOUNT-dev"
> aws s3api create-bucket --bucket $BUCKET --region $REGION --create-bucket-configuration LocationConstraint=$REGION
> aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Enabled
> aws s3api put-bucket-encryption --bucket $BUCKET --server-side-encryption-configuration '{ "Rules": [ { "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" } } ] }'
> aws s3api put-public-access-block --bucket $BUCKET --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
> ```

---

## 2) Інфраструктура (Terraform)

```powershell
terraform init -reconfigure
terraform plan -out=tfplan
terraform apply tfplan

# kubeconfig для доступу до кластера
aws eks update-kubeconfig --region us-west-2 --name lesson-6-eks

# перевірка нод
kubectl get nodes

---

## 3) Образ (Docker + ECR)

$REGION = "us-west-2"
$ACCOUNT = "938094936571"
$ECR = "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/lesson-6-django"
$TAG = "0.1.0"

# логін у ECR
$PASS = (aws ecr get-login-password --region $REGION).Trim()
docker login --username AWS --password $PASS "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

# збірка та пуш
docker build -t django-app:$TAG -f .\django\Dockerfile .\django
docker tag django-app:$TAG "$ECR:$TAG"
docker push "$ECR:$TAG"

# перевірка тегів
aws ecr list-images --repository-name lesson-6-django --query 'imageIds[].imageTag'


## 4) PostgreSQL у кластері

kubectl apply -f .\k8s\postgres.yaml
kubectl get pods -w
kubectl get svc db



Змінні середовища, які використовує застосунок (через ConfigMap у Helm):

POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=apppassword
DB_HOST=db
DB_PORT=5432
DJANGO_DEBUG=True

5) Деплой через Helm

У charts\django-app\values.yaml мають бути налаштовані:

image.repository = 938094936571.dkr.ecr.us-west-2.amazonaws.com/lesson-6-django

image.tag = "0.1.0"

service: type LoadBalancer, port 80, targetPort 8000

autoscaling: min 2, max 6, targetCPU 70

envConfig із змінними вище

# metrics-server (для HPA)
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm install metrics-server metrics-server/metrics-server -n kube-system
kubectl rollout status deployment/metrics-server -n kube-system

# деплой застосунку
helm install django-app .\charts\django-app\

# перевірка ресурсів
kubectl get pods
kubectl get svc
kubectl get hpa

6) Доступ

Отримай зовнішню адресу (DNS) сервісу типу LoadBalancer:

kubectl get svc django-app


Відкрий у браузері:

http://<EXTERNAL-IP>/



## 7) Приймальні перевірки

# кластер працює
kubectl get nodes -o wide

# ECR містить образ
aws ecr describe-repositories --repository-names lesson-6-django
aws ecr list-images --repository-name lesson-6-django --query 'imageIds[].imageTag'

# ресурси від Helm
helm list
kubectl get deploy,rs,pods
kubectl get svc django-app
kubectl get hpa django-app

# ConfigMap та env у контейнері
kubectl get cm -l app.kubernetes.io/name=django-app -o name
kubectl exec -it deploy/django-app -- sh -lc 'env | grep -E "POSTGRES|DB_HOST|DJANGO_DEBUG"'


## 8) Прибирання 
helm uninstall django-app
kubectl delete -f .\k8s\postgres.yaml
helm uninstall metrics-server -n kube-system
terraform destroy -auto-approve