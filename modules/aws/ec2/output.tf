output "security_group_web_id" {
  value = "${aws_security_group.this.id}"
}

output "ec2_obj_web1" {
  value = "${aws_instance.web_a}"
}

output "ec2_obj_web2" {
  value = "${aws_instance.web_b}"
}

output "ec2_web1_id" {
  value = "${aws_instance.web_a.id}"
}

output "ec2_web2_id" {
  value = "${aws_instance.web_b.id}"
}

#output "ec2_eip_web1" {
#  value = "${aws_eip.web_a.public_ip}"
#}
#
#output "ec2_eip_web2" {
#  value = "${aws_eip.web_b.public_ip}"
#}

