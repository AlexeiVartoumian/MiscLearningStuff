
output "alb_dns_name" {
    value = aws_lb.webapp.dns_name
    description = "the dns name of the app load balancer"
} 

output "asg_name" {
    value = aws_autoscaling_group.webapp.name
    description = "nameof autoscaling group"
}