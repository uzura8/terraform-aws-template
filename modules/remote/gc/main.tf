variable "key_name" {}
variable "public_ip" {}
variable "rds_obj" {}

locals {
  private_key_file = "var/${var.key_name}.id_rsa"
}

#resource "null_resource" "local-gc-config" {
#  depends_on = [var.rds_obj]
#  provisioner "local-exec" {
#    command = "/bin/bash bin/local_make_gc_config.sh"
#  }
#}

#resource "null_resource" "provision-web" {
#  depends_on = [null_resource.local-gc-config]
#  connection {
#    host        = "${var.public_ip}"
#    type        = "ssh"
#    port        = 22
#    user        = "ec2-user"
#    private_key = file("${local.private_key_file}")
#    timeout     = "10m"
#    agent       = false
#  }
#
#  provisioner "file" {
#    source      = "var/gc_configs"
#    destination = "/home/ec2-user"
#  }
#}

resource "null_resource" "ec2-ssh-setup-gc" {
  depends_on = [null_resource.provision-web]
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

