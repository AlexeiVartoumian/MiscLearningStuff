
output "web_server_sg_id" {
    value = aws_security_group.web_server.id
    description = "the if of the web server secutiry group"
}


output "db_sg_id"{
    value =aws_security_group.db.id
    description = "the id of the database security group"
}
