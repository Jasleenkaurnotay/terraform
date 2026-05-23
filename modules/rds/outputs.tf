output "rds_endpoint" {
    value = aws_db_instance.rds_db.endpoint
}

output "rds_db_name" {
    value = aws_db_instance.rds_db.db_name
}