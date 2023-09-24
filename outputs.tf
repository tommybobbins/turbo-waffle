output "SSH-string" {
  description = "Turbo Waffle SSH"
  value       = join("", ["ssh -i ${var.project_name}.pem -oPort=2020 ubuntu@", aws_instance.turbowaffle.ipv6_addresses[0]])
}

