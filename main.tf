# main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Creation
resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

# Subnet Creation
resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  network      = google_compute_network.custom_vpc.self_link
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  network      = google_compute_network.custom_vpc.self_link
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
}

# Firewall Rules
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.custom_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.custom_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# Route Table (Default internet route)
resource "google_compute_route" "default_route" {
  name       = "default-route"
  network    = google_compute_network.custom_vpc.self_link
  dest_range = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}

# Compute Instance
resource "google_compute_instance" "web_instance" {
  name         = "web-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.custom_vpc.self_link
    subnetwork = google_compute_subnetwork.subnet_1.self_link
    access_config {}
  }
}

# Load Balancer (Simplified, using external IP)
resource "google_compute_global_address" "lb_ip" {
  name = "lb-ip"
}

# Health Check for Load Balancer
resource "google_compute_health_check" "default" {
  name = "default-health-check"

  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "backend" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.default.self_link]
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend.self_link
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name       = "http-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}
