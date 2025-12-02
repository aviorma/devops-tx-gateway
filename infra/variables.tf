variable "gcp_project" {
  description = "The GCP project ID where resources will be provisioned."
}

variable "gcp_region" {
  description = "The GCP region for the cluster (e.g. us-central1, europe-west1)."
  default     = "us-central1"
}

variable "node_locations" {
  description = "List of zones within the region for multi-AZ deployment. Minimum 3 zones recommended for HA."
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "env" {
  description = "The environment (staging or production)."
}

variable "initial_node_count" {
  description = "Initial node count per zone for GKE cluster."
  default     = 1
}

variable "min_node_count" {
  description = "Minimum node count per zone for autoscaling."
  default     = 1
}

variable "max_node_count" {
  description = "Maximum node count per zone for autoscaling."
  default     = 3
}

variable "machine_type" {
  description = "Machine type for GKE nodes (e.g., e2-medium)."
  default     = "e2-medium"
}

variable "owner_tag" {
  description = "Owner or team label for resources. Used in naming and GCP labels."
  default     = "tx-gateway-team"
}

variable "gke_network" {
  description = "VPC network name for GKE (must exist or be created)."
  default     = "default"
}

variable "gke_subnetwork" {
  description = "Subnetwork name for GKE (must exist or be created)."
  default     = "default"
}
