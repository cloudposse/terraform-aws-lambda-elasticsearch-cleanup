output "security_group_id" {
  value       = "${aws_security_group.default.id}"
  description = "Security Group ID of the Lambda "
}
