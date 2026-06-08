# Outputs de GitOps ArgoCD
# TODO: Completar con outputs reales de los recursos implementados

output "argocd_namespace" {
  description = "Namespace donde se instaló ArgoCD"
  value       = var.argocd_namespace
}

output "argocd_server_url" {
  description = "URL del servidor ArgoCD"
  value       = "TODO: Add ArgoCD Server URL"
}

output "argocd_ingress_ip" {
  description = "IP pública del Ingress de ArgoCD"
  value       = "TODO: Add Ingress IP"
}

output "argocd_admin_password" {
  description = "Contraseña inicial para administrador de ArgoCD"
  value       = "TODO: Add Admin Password"
  sensitive   = true
}

output "argocd_cli_login_command" {
  description = "Comando para login con CLI de ArgoCD"
  value       = "TODO: argocd login <ARGOCD_SERVER_URL> --username admin --password <PASSWORD>"
}

output "kubeconfig_path" {
  description = "Ruta al kubeconfig del cluster OKE"
  value       = "~/.kube/config"
}

output "repository_configured" {
  description = "Si el repositorio Git está configurado"
  value       = var.repository_url != ""
}

output "slack_notifications_configured" {
  description = "Si las notificaciones de Slack están configuradas"
  value       = var.notification_slack_webhook != ""
}

output "auto_sync_enabled" {
  description = "Si la sincronización automática está habilitada"
  value       = var.enable_auto_sync
}

output "self_heal_enabled" {
  description = "Si el auto-healing está habilitado"
  value       = var.enable_self_heal
}

output "monitoring_enabled" {
  description = "Si el monitoreo de OCI está habilitado"
  value       = var.enable_monitoring
}

output "argocd_access_instructions" {
  description = "Instrucciones para acceder a ArgoCD"
  value = {
    web_ui = "1. Navegar a ArgoCD URL (usar Ingress IP o port-forward)"
    port_forward = "kubectl port-forward -n argocd svc/argocd-server 8080:443"
    login = "argocd login <URL> --username admin --password <PASSWORD>"
    add_repo = "argocd repo add <GIT_REPO_URL> --username <USER> --password <TOKEN>"
    create_app = "argocd app create <APP_NAME> --repo <REPO> --path <PATH> --dest-server https://kubernetes.default.svc"
    next_steps = [
      "1. Acceder a ArgoCD UI",
      "2. Agregar repositorio Git",
      "3. Crear aplicación",
      "4. Sincronizar cambios",
      "5. Monitorear el estado"
    ]
  }
}

output "oke_cluster_info" {
  description = "Información del cluster OKE"
  value = {
    cluster_id   = var.oke_cluster_id
    cluster_name = var.oke_cluster_name
    region       = var.region
    kubernetes_version = "TODO: Add from cluster info"
  }
}

output "helm_release_status" {
  description = "Estado del Helm release de ArgoCD"
  value       = "TODO: Add Helm Release Status"
}

output "networking_info" {
  description = "Información de networking para ArgoCD"
  value = {
    ingress_enabled = var.enable_ingress
    ingress_class   = var.ingress_class_name
    service_type    = var.enable_ingress ? "ClusterIP" : "LoadBalancer"
    port_https      = 443
    port_http       = 80
  }
}

output "backup_recommendations" {
  description = "Recomendaciones para backup de ArgoCD"
  value = {
    backup_namespace = "Respaldar el namespace argocd completo"
    backup_configmaps = [
      "argocd-cm",
      "argocd-secret",
      "argocd-rbac-cm"
    ]
    backup_crds = [
      "applications.argoproj.io",
      "appprojects.argoproj.io",
      "applicationsets.argoproj.io"
    ]
    backup_command = "kubectl get -n argocd -o yaml | tee argocd-backup.yaml"
  }
}

output "security_considerations" {
  description = "Consideraciones de seguridad"
  value = {
    rbac_enabled            = var.enable_rbac
    secret_encryption       = "Habilitar encriptación etcd en OKE"
    network_policies        = "Considerar network policies restrictivas"
    repository_auth_method  = var.repository_username != "" ? "Basic Auth" : "SSH Key"
    ingress_tls             = "Configurar TLS para Ingress en producción"
  }
}
