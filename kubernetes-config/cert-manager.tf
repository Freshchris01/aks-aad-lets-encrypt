resource "helm_release" "cert_manager" {

	depends_on = [ kubernetes_namespace.ingress ]

	name = "cert-manager"
	namespace = kubernetes_namespace.ingress.metadata.0.name

	repository = "https://charts.jetstack.io"
	chart      = "cert-manager"

	set {
		name= "installCRDs"
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
    count     = length(data.kubectl_file_documents.cert_manager.documents)
    yaml_body = element(data.kubectl_file_documents.cert_manager.documents, count.index)
    override_namespace = "ingress"
}

resource "azurerm_federated_identity_credential" "cert" {
	resource_group_name = var.rg_name
	name = "cert-manager"
	issuer = var.issuer_url
	subject = "system:serviceaccount:ingress:cert-manager"
	parent_id = var.federated_identity_id
	audience = [ "api://AzureADTokenExchange" ]
}