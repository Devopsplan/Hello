terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable GKE API
resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

# -------------------------
# VPC (Equivalent of AWS VPC)
# -------------------------
resource "google_compute_network" "vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

# Subnet (Equivalent of private subnet)
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id

  # Pods range
  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  # Services range
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# -------------------------
# Cloud Router + NAT (AWS NAT Gateway equivalent)
# -------------------------
resource "google_compute_router" "router" {
  name    = "nat-router"
  network = google_compute_network.vpc.name
  region  = var.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-config"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# -------------------------
# GKE Cluster (EKS equivalent)
# -------------------------
resource "google_container_cluster" "gke" {
  name     = "my-cluster"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [
    google_project_service.container
  ]
}

# -------------------------
# Node Pool (EKS Node Group equivalent)
# -------------------------
resource "google_container_node_pool" "nodes" {
  name       = "default-node-pool"
  cluster    = google_container_cluster.gke.name
  location   = var.region

  node_count = 2

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = "e2-medium"  # t3.medium equivalent

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "dev"
    }
  }
}