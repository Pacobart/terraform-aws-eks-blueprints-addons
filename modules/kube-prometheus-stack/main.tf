locals {
  name      = try(var.helm_config.name, "kube-prometheus-stack")
  namespace = try(var.helm_config.namespace, local.name)

  argocd_gitops_config = {
    enable = true
  }
}

# https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml
module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://prometheus-community.github.io/helm-charts"
      version          = "45.7.1"
      namespace        = local.namespace
      create_namespace = local.namespace != "kube-system" ? try(var.helm_config.create_namespace, true) : false
      values = [templatefile("${path.module}/values.yaml", {
        aws_region = var.addon_context.aws_region_name
      })]
      description = "kube-prometheus-stack helm Chart deployment configuration"
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
