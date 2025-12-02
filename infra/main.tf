provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

resource "google_container_cluster" "tx_gateway" {
  name     = "${var.owner_tag}-tx-gateway-${var.env}"
  location = var.gcp_region
  
  # Distribute nodes across at least 3 availability zones for high availability
  node_locations = var.node_locations
  
  # Remove default node pool to use custom node pool configuration
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = var.gke_network
  subnetwork = var.gke_subnetwork
  min_master_version = "latest"
  
  resource_labels = {
    environment = var.env
    owner       = var.owner_tag
    team        = var.owner_tag
    project     = var.gcp_project
    managed_by  = "terraform"
  }
  
  # Optionally, enable additional GKE features
  # enable_autopilot = true
}

# Custom node pool with multi-zone configuration
resource "google_container_node_pool" "tx_gateway_nodes" {
  name       = "${var.owner_tag}-tx-gateway-${var.env}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.tx_gateway.name
  
  # Initial node count per zone (total = initial_node_count * number of zones)
  initial_node_count = var.initial_node_count
  
  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
    labels = {
      team        = var.owner_tag
      environment = var.env
    }
    tags = ["k8s", "tx-gateway", var.env, var.owner_tag]
  }
  
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
