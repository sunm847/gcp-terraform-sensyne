# Configure the Google Cloud tfstate file location
terraform {
  backend "gcs" {
    bucket = "Sensyne-admin-demo"
    prefix = "sensyne-project"
  }
}
