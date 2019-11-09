# path of private key to use for access to server
output "private_key_file" {
  value = "${local.private_key_file}"
}

# private key value
output "private_key_pem" {
  value = "${tls_private_key.keygen.private_key_pem}"
}

# path of public key
output "public_key_file" {
  value = "${local.public_key_file}"
}

# public key value
output "public_key_openssh" {
  value = "${tls_private_key.keygen.public_key_openssh}"
}
