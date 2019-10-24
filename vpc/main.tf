# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "sensyne-vpc"
  auto_create_subnetworks = "false"
}
