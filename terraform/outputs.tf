output "ec2_instance_id" {
  value = aws_instance.mb_web_server.id
}

output "ec2_public_ip" {
  value = aws_instance.mb_web_server.public_ip
}

output "alb_dns_name" {
  value = aws_lb.mb_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.mb_tg.arn
}
