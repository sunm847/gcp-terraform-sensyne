provider "google" {
  version = "~> 2.9.0"
  project = "${var.project}"
  region  = "${var.region}"

  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]

provider "random" {}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "terraform-${var.project_name}"
}

resource "google_project" "project" {
  name            = "terraform-${var.project_name}"
  project_id      = "${random_id.id.hex}"
  billing_account = "${var.billing_account}"
  org_id          = "${var.org_id}"
}

resource "google_project_services" "project" {
  project = "${google_project.project.project_id}"

  services = [
    "bigquery-json.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "deploymentmanager.googleapis.com",
    "dns.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "servicemanagement.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

# use newly created Google storage bucket to keep our tfstate files
data "terraform_remote_state" "project_id" {
  backend   = "gcs"
  config = {
      bucket  = "Sensyne-admin-demo"
      prefix  = "sensyne-project"
    }
  }

  module "vpc" {
    source = "./vpc"
  }

  module "subnet" {
    source      = "./subnet"
    region      = "${var.region}"
    vpc_name     = "${module.vpc.vpc_name}"
    subnet_cidr = "${var.subnet_cidr}"
  }

  module "firewall" {
    source        = "./firewall"
    vpc_name       = "${module.vpc.vpc_name}"
    ip_cidr_range = "${module.subnet.ip_cidr_range}"
  }

  module "cloudsql" {
    source                     = "./cloudsql"
    region                     = "${var.region}"
    availability_type          = "${var.availability_type}"
    sql_instance_size          = "${var.sql_instance_size}"
    sql_disk_type              = "${var.sql_disk_type}"
    sql_disk_size              = "${var.sql_disk_size}"
    sql_require_ssl            = "${var.sql_require_ssl}"
    sql_master_zone            = "${var.sql_master_zone}"
    sql_connect_retry_interval = "${var.sql_connect_retry_interval}"
    sql_replica_zone           = "${var.sql_replica_zone}"
    sql_user                   = "${var.sql_user}"
    sql_pass                   = "${var.sql_pass}"
  }

resource "google_container_cluster" "default" {
  name        = "${var.name}"
  project     = "${var.project}"
  description = "Sensyne Cluster"
  location    = "${var.location}"
  zone        = "us-central1-c"

  remove_default_node_pool = true
  initial_node_count = "${var.initial_node_count}"

  master_auth {
    username = "${var.admin_username}"
    password = "${var.admin_password}"

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "default" {
  name       = "${var.name}-node-pool"
  project     = "${var.project}"
  location   = "${var.location}"
  cluster    = "${google_container_cluster.default.name}"
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "${var.machine_type}"

    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
          "https://www.googleapis.com/auth/compute",
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/logging.write",
          "https://www.googleapis.com/auth/monitoring",
        ]
  }
