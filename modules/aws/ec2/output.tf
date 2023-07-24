output "elastic_ip_of_web" {
  value = length(aws_eip.this) > 0 ? aws_eip.this[0].public_ip : ""
}

output "security_group_web_id" {
  value = aws_security_group.this.id
}

output "ec2_obj" {
  value = aws_instance.web1
}
