

resource "aws_db_subnet_group" "webapp" {

    name = var.db_subnet_group_name
    subnet_ids = var.private_subnet_ids

    tags = {
        Name = "webapp DB subnet group"
    }
}

resource "aws_db_instance" "webapp" {

    identifier = "webapp-db"
    engine = "mysql"
    engine_version = "8.0"
    isntance_class = var.db_instance_class
    allocated_storage = 20
    storage_type = "gp2"
    db_name = var.db_name
    username = var.db_user
    password = var.db_password
    parameter_group_name  = "default.mysql8.0"

    vpc_security_group_ids = [var.db_sg_id]
    db_subnet_group_name = aws_db_subnet_group.webapp.name
    skip_final_snapshot = true

    tags = {
        Name = "Webapp Database"
    }
 }