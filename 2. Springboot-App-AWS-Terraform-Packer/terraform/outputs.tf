output "asg_name" {
  value       = aws_autoscaling_group.app_server_asg.name
  description = "The name of the Autoscaling Group"
}
