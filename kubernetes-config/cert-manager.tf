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