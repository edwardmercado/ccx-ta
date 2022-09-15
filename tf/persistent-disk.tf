resource "google_compute_disk" "disk" {
  name  = "ccx-disk"
  zone  = "asia-east2-a"
  labels = {
    environment = "nexus"
  }
  physical_block_size_bytes = 4096
}