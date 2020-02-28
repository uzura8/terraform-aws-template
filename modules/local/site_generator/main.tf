variable "git_repo_url" {}
variable "strage_name" {}
variable "python2_version" {}
variable "python3_version" {}


resource "null_resource" "local-site-genarater" {
  depends_on = [var.strage_name]
  provisioner "local-exec" {
    command = "pyenv global ${var.python3_version}"
  }

  provisioner "local-exec" {
    command = "/bin/bash bin/setup_site_generater.sh ${var.git_repo_url} ${var.strage_name}"
  }

  provisioner "local-exec" {
    command = "pyenv global ${var.python2_version}"
  }

  provisioner "local-exec" {
    command = "gsutil cp -r var/site-generator/public/* gs://${var.strage_name}"
  }

  provisioner "local-exec" {
    command = "gsutil acl ch -r -u AllUsers:R gs://${var.strage_name}"
  }
}
