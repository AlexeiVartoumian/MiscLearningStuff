
output "db_instance_endpoint" {
    value = aws_db_instance.webapp.endpoint
    description = "the connection endpoint for the database"
}

output "db_instance_name" {
    value  = aws_db_instance.webapp.db_name
    description = "the name of the database"
}
