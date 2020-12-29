# inlets PRO and Google Cloud Identity-Aware Proxy

This repo contains a Terraform Module for how to deploy an [inlets PRO](https://inlets.dev) exit-node, protected with [Cloud Identity-Aware Proxy](https://cloud.google.com/iap), on
[GCP](https://cloud.google.com/) using [Terraform](https://www.terraform.io/).

## What's a Terraform Module?

A Terraform Module refers to a self-contained packages of Terraform configurations that are managed as a group. This repo
is a Terraform Module and contains many "submodules" which can be composed together to create useful infrastructure patterns.

## How do you use this module?

This repository defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this repository:

```hcl
module "postgresql" {
  source     = "../"
  name       = "postgresql"
  zone       = var.zone
  network    = google_compute_network.inlets.name
  subnetwork = google_compute_subnetwork.inlets.name
  ports      = [3306]
  members = [
    "user:jsiebens@gmail.com",
    "user:johan.siebens@gmail.com",
  ]
}
```

A complete example is available in the [example](https://github.com/jsiebens/terraform-google-inlets-iap/tree/main/example) folder. 

## Blog post

[Control Access to your on-prem services with Cloud IAP and inlets PRO](https://johansiebens.dev/posts/2020/12/control-access-to-your-on-prem-services-with-cloud-iap-and-inlets-pro/)
