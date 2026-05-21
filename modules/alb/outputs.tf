output "alb_dns_name" {
    value = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_tg_id" {
    value = aws_lb_target_group.alb_tg.id
}

output "alb_tg_lb_id" {
    value = aws_lb_target_group.alb_tg.arn
}

