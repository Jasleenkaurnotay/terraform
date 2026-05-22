output "ecs_cluster_id" {
    value = aws_ecs_cluster.ecs.id
}

output "ecs_cluster_name" {
    value = aws_ecs_cluster.ecs.name
}

output "ecs_lg_id" {
    value = aws_cloudwatch_log_group.ecs_lg.id
}