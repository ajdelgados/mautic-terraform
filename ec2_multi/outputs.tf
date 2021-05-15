output "public_ip" {
  description = "The Public IP of the EC2"
  value = tomap({
    for k, instance in module.mautic-instance : k => instance.public_ip
  })
}