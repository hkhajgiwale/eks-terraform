output "bastion_public_ip" {
  value       = aws_instance.bastion_instance.public_ip
  description = "The public IP address of the Bastion Host instance"
}
