variable "location" {
  type    = string
  default = "westeurope"
}

resource "random_id" "cluster_name" {
  byte_length = 5
}

locals {
  cluster_name = "tf-k8s-${random_id.cluster_name.hex}"
}

variable "tenant_id" {
	type = string
}

variable "aad_server_id" {
	type = string
	default = "6dae42f8-4368-4678-94ff-3960e28e3630" # This is hardcoded according to: https://spacelift.io/blog/terraform-kubernetes-provider
}

variable "client_id" {
	type = string
}

variable "client_secret" {
	type = string
}