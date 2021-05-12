output "public_ip" {
  description = "The Public IP of the EC2"
  value       = aws_instance.om-instance.public_ip
}