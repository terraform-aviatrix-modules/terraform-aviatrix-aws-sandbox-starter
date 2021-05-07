output "ip" {
  description = "The IP of the sst instance"
  value       = var.private ? aws_instance.sst.private_ip : aws_instance.sst.public_ip
}
