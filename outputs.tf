# ALB DNS name
output "skyline_alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value = aws_lb.skyline_alb.dns_name
}

# ALB zone ID
output "skyline_alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value = aws_lb.skyline_alb.zone_id
}

# Target group ARN
output "skyline_tg_arn" {
  description = "ARN of the target group"
  value = aws_lb_target_group.skyline_alb_tg.arn
}

# Auto Scaling Group name
output "skyline_asg_name" {
  description = "Name of the Auto Scaling Group"
  value = aws_autoscaling_group.skyline_asg.name
}