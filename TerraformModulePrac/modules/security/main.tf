
resource "aws_security_group" "web_server" {

    name = "web-server-sg"
    description = "security group for web servers"
    vpc_id = var.vpc_id

    ingress {
        description= "htpp from anywhere"
        from_port  = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0 
        protocol  = "-1"
        
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "we-server-sg"
    }   
}

resource "aws_security_group" "db" {
    name = "database-sg"
    description = "security group for database"
    vpc_id = var.vpc_id

    ingress {
        description = "mysql from web servers"
        from_port = 3306
        to port = 3306
        security_groups = [aws_security_grou.web_server.id]
    }
    tags = {
        Name = "database-sg"
    }
}