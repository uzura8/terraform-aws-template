output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.this.cidr_block}"
}

output "subnet_public_a_web_id" {
  value = "${aws_subnet.public_a_web.id}"
}

output "subnet_public_b_web_id" {
  value = "${aws_subnet.public_b_web.id}"
}

output "subnet_group_db_name" {
  value = "${aws_db_subnet_group.private.name}"
}
