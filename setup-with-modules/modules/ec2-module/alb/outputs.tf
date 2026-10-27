
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "alb_url" {
  description = "URL to access the web page"
  value       = "http://${aws_lb.web_alb.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.web_tg.arn
}
