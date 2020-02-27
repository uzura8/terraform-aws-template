variable "common_prefix" {}
variable "gcp_credential_path" {}
variable "gcp_project" {}
variable "gcp_region" {}
variable "site_domain" {}
variable "gcs_class" {}
variable "git_repo_url" {}
variable "python2_version" {}
variable "python3_version" {}

provider "google" {
  credentials = "${file("${var.gcp_credential_path}")}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

module "module_gcp_strage" {
  source      = "./modules/gcp/strage"
  site_domain = "${var.site_domain}"
  gcp_project = "${var.gcp_project}"
  gcp_region  = "${var.gcp_region}"
  gcs_class   = "${var.gcs_class}"
}

# Local
module "module_site_generator" {
  source          = "./modules/local/site_generator"
  git_repo_url    = "${var.git_repo_url}"
  strage_name     = "${module.module_gcp_strage.strage_name}"
  python2_version = "${var.python2_version}"
  python3_version = "${var.python3_version}"
}

