variable zone {
  type = string
}

variable network {
  type    = string
  default = "default"
}

variable subnetwork {
  type    = string
  default = null
}

variable machine_type {
  type    = string
  default = "f1-micro"
}

variable name {
  type    = string
  default = null
}

variable ssh_port {
  type    = number
  default = 22
}

variable source_ranges {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable ports {
  type    = list(number)
  default = []
}

variable members {
  type    = list(string)
  default = []
}