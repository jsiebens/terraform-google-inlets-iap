provider "google" {
  project = var.project
  region  = var.region
}

resource "google_compute_network" "inlets" {
  name                    = "inlets"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "inlets" {
  name          = "inlets"
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.inlets.id
}

module "postgresql" {
  source     = "../"
  name       = "postgresql"
  zone       = var.zone
  network    = google_compute_network.inlets.name
  subnetwork = google_compute_subnetwork.inlets.name
  ports      = [3306]
}

module "rabbitmq" {
  source     = "../"
  name       = "rabbitmq"
  zone       = var.zone
  network    = google_compute_network.inlets.name
  subnetwork = google_compute_subnetwork.inlets.name
  ports      = [5672, 15672, 25672]
}

output "postgresql" {
  value = module.postgresql.inlets_cmd
}

output "rabbitmq" {
  value = module.rabbitmq.inlets_cmd
}
