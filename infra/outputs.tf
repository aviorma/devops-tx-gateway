output "cluster_name" {
  value = google_container_cluster.tx_gateway.name
}

output "endpoint" {
  value = google_container_cluster.tx_gateway.endpoint
}

output "kubeconfig" {
  value = google_container_cluster.tx_gateway.master_auth[0].cluster_ca_certificate
  description = "Kubeconfig CA certificate. (As example — for real access, expand this output.)"
}
