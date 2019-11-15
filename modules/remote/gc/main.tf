variable "key_name" {}
variable "public_ip" {}

locals {
  private_key_file = "var/${var.key_name}.id_rsa"
}

resource "null_resource" "ec2-ssh-connection" {
  provisioner "remote-exec" {
    scripts = [
      "bin/remote_setup_gc.sh"
    ]

    connection {
      host        = "${var.public_ip}"
      type        = "ssh"
      port        = 22
      user        = "ec2-user"
      private_key = file("${local.private_key_file}")
      timeout     = "10m"
      agent       = false
    }
  }
}
