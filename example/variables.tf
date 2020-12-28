variable project {
  type = string
}

variable region {
  type    = string
  default = "europe-west1"
}

variable zone {
  type    = string
  default = "europe-west1-b"
}

variable ip_cidr_range {
  type    = string
  default = "10.2.0.0/16"
}