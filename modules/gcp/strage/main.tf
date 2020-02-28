variable "site_domain" {}
variable "gcp_project" {}
variable "gcp_region" {}
variable "gcs_class" {}


resource "google_storage_bucket" "site-file-store" {
  name          = "${var.site_domain}"
  project       = "${var.gcp_project}"
  location      = "${var.gcp_region}"
  storage_class = "${var.gcs_class}"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_access_control" "public_rule" {
  depends_on = [google_storage_bucket.site-file-store]
  bucket     = google_storage_bucket.site-file-store.name
  role       = "READER"
  entity     = "allUsers"
}

