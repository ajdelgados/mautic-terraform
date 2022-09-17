output "orquesta_zone_id" {
  description = "Zone ID for orquesta.agency"
  value = aws_route53_zone.primary.zone_id
}

output "orquesta_zone_name" {
  description = "Zone ID for orquesta.agency"
  value = aws_route53_zone.primary.name
}