resource "helm_release" "cert_manager" {

  depends_on = [kubernetes_namespace.ingress]

  name      = "cert-manager"
  namespace = kubernetes_namespace.ingress.metadata.0.name

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [templatefile("${path.module}/manifests/cert-manager-values.yaml", {})]
}

data "kubectl_file_documents" "cert_manager" {
  content = file("${path.module}/manifests/cert-manager.yaml")
}

resource "kubectl_manifest" "cert_manager" {
  depends_on = [
    kubernetes_namespace.ingress,
  ]
  count              = length(data.kubectl_file_documents.cert_manager.documents)
  yaml_body          = element(data.kubectl_file_documents.cert_manager.documents, count.index)
  override_namespace = "ingress"
}

resource "azurerm_federated_identity_credential" "cert" {
  resource_group_name = var.rg_name
  name                = "cert-manager"
  issuer              = var.issuer_url
  subject             = "system:serviceaccount:ingress:cert-manager"
  parent_id           = var.federated_identity_id
  audience            = ["api://AzureADTokenExchange"]
}

resource "kubectl_manifest" "staging_issuer" {
  yaml_body = <<-EOF
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: letsencrypt-staging
    namespace: ingress
  spec:
    acme:
      server: https://acme-staging-v02.api.letsencrypt.org/directory
      email: ${var.cert_mail}
      privateKeySecretRef:
        name: letsencrypt-staging
      solvers:
      - dns01:
          azureDNS:
            resourceGroupName: ${var.rg_name}
            subscriptionID: ${var.subscription_id}
            hostedZoneName: fs557.org
            environment: AzurePublicCloud
            managedIdentity:
              clientID: ${var.identity_client_id}
    EOF
}

resource "kubectl_manifest" "production_issuer" {
  yaml_body = <<-EOF
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: letsencrypt-production
    namespace: ingress
  spec:
    acme:
      server: https://acme-v02.api.letsencrypt.org/directory
      email: ${var.cert_mail}
      privateKeySecretRef:
        name: letsencrypt-production
      solvers:
      - dns01:
          azureDNS:
            resourceGroupName: ${var.rg_name}
            subscriptionID: ${var.subscription_id}
            hostedZoneName: fs557.org
            environment: AzurePublicCloud
            managedIdentity:
              clientID: ${var.identity_client_id}
    EOF
}