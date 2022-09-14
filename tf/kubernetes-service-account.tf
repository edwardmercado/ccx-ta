
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "service-a" {
  account_id = "service-a"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "service-a" {
  project = "ccx-technical-assesment"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.service-a.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_member" "service-a" {
  service_account_id = google_service_account.service-a.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:ccx-technical-assesment.svc.id.goog[nexus-dev/service-a]"
}

resource "google_project_iam_member" "allow_image_pull" {
  project = "ccx-technical-assesment"
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.service-a.email}"
}