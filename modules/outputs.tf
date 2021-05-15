output "public_ip" {
  description = "The Public IP of the EC2"
  value       = aws_instance.this.public_ip
}