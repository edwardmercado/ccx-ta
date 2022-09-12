terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.35.0"
    }
  }
}

provider "google" {
  project = "ccx-technical-assesment"
  region  = "asia-east2"
  zone    = "asia-east2-a"
}