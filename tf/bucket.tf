resource "google_storage_bucket" "static-site" {
  name          = "ccx-ta-storage-bucket"
  location      = "ASIA-EAST2"
  force_destroy = true

  uniform_bucket_level_access = true
}