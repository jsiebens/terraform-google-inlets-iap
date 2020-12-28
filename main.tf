resource "random_string" "id" {
  length  = 6
  upper   = false
  special = false
}

locals {
  name = var.name != null && var.name != "" ? format("inlets-%s", var.name) : format("inlets-%s", random_string.id.result)
}

resource "google_compute_address" "inlets" {
  name = local.name
}

resource "google_compute_firewall" "inlets-firewall-tunnel" {
  name    = format("%s-allow-inlets", local.name)
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["8123"]
  }
  source_ranges           = var.source_ranges
  target_service_accounts = [google_service_account.inlets.email]
}

resource "google_compute_firewall" "inlets-firewall-iap" {
  name    = format("%s-allow-iap", local.name)
  network = var.network
  allow {
    protocol = "tcp"
    ports    = concat([var.ssh_port], var.ports)
  }
  source_ranges           = ["35.235.240.0/20"]
  target_service_accounts = [google_service_account.inlets.email]
}

resource "random_string" "token" {
  length  = 32
  special = false
}

resource "google_service_account" "inlets" {
  account_id = local.name
}

resource "google_project_iam_member" "inlets-log-writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.inlets.email}"
}

data "template_file" "inlets" {
  template = file("${path.module}/templates/startup.sh")
  vars = {
    token    = random_string.token.result
    ssh_port = var.ssh_port
  }
}

resource "google_compute_instance" "inlets" {
  name         = local.name
  zone         = var.zone
  machine_type = var.machine_type

  metadata_startup_script = data.template_file.inlets.rendered

  metadata = {
    block-project-ssh-keys = "TRUE"
    enable-oslogin         = "TRUE"
  }

  boot_disk {
    initialize_params {
      size  = 50
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {
      nat_ip = google_compute_address.inlets.address
    }
  }

  tags = [local.name]

  shielded_instance_config {
    enable_secure_boot = true
  }

  service_account {
    email = google_service_account.inlets.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

}

resource "google_iap_tunnel_instance_iam_binding" "enable_iap" {
  count    = length(var.members) == 0 ? 0 : 1
  zone     = var.zone
  instance = google_compute_instance.inlets.id
  role     = "roles/iap.tunnelResourceAccessor"
  members  = var.members
}

output "token" {
  value = random_string.token.result
}

output "address" {
  value = google_compute_address.inlets.address
}

output "inlets_cmd" {
  value = format("inlets-pro client --url=wss://%s:8123/connect --token=%s --license-file=$HOME/inlets-license --upstream=localhost --ports='%s'", google_compute_address.inlets.address, random_string.token.result, join(",", var.ports))
}