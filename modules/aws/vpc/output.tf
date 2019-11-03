output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "subnet_public_web_id" {
  value = "${aws_subnet.public_web.id}"
}

output "subnet_group_db_name" {
  value = "${aws_db_subnet_group.main.name}"
}
