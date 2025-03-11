# variables.tf
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "google_credentials_file" {
  description = "Path to the GCP service account JSON key file"
  type        = string
}
