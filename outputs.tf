# outputs.tf
output "vpc_name" {
  description = "The name of the created VPC"
  value       = google_compute_network.custom_vpc.name
}

output "subnet_1_name" {
  description = "The name of subnet 1"
  value       = google_compute_subnetwork.subnet_1.name
}

output "subnet_2_name" {
  description = "The name of subnet 2"
  value       = google_compute_subnetwork.subnet_2.name
}

output "external_ip" {
  description = "The external IP of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}
