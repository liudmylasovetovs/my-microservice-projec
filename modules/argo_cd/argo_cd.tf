resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  replace      = true
  force_update = true
  chart      = "argo-cd"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  create_namespace = true
}

locals {
  rds_host = split(":", var.rds_endpoint)[0]
}

resource "helm_release" "argo_apps" {
  name             = "${var.name}-apps"
  chart            = "${path.module}/charts"
  namespace        = var.namespace
  create_namespace = false
  dependency_update = true

  values = [
    templatefile("${path.module}/charts/values.yaml", {
      github_username = var.github_username
      github_token = var.github_token
      github_repo_url = var.github_repo_url
      rds_host = local.rds_host
      rds_username = var.rds_username
      rds_db_name = var.rds_db_name
      rds_password = var.rds_password
    })
  ]

  depends_on = [helm_release.argo_cd]
