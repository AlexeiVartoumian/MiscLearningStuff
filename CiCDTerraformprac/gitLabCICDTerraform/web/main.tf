resource "aws_instance" "server" {
    ami = "ami-0b53285ea6c7a08a7"
    instance_type = "t2.micro"
    subnet_id = var.sn
    security_groups = [var.sg]

    tags = {
        Name = "myserver" 
    }
}