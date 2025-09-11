variable "name" {
  description = "Назва Helm-релізу"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository name"
  type        = string
}

variable "chart_version" {
  description = "Версія Argo CD чарта"
  type        = string
  default     = "5.46.4"
}

variable "rds_username" {
  description = "Ім'я користувача для RDS"
  type        = string
}
variable "rds_db_name" {
  description = "Назва бази даних для RDS"
  type        = string
}
variable "rds_password" {
  description = "Пароль для RDS"
  type        = string
  sensitive   = true
}
variable "rds_endpoint" {
  description = "Endpoint для RDS"
  type        = string
}
