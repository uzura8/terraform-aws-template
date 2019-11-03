# for console output
output "elastic_ip_of_web" {
  value = "${aws_eip.this.public_ip}"
}

output "security_group_web_id" {
  value = "${aws_security_group.this.id}"
}
