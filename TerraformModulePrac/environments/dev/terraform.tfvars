module "TerraformModulePrac" {
    source = "../.."

    aws_region  ="eu-west-2"
    vpc_cidr  = "10.0.0.0/16"
    public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
    availability_zones = ["eu-west-2a", "eu-west-2b"]
    isntance_type = "t2.micro"
    key_name = "dev-key"
    max_size = 4
    min_size = 1
    desired_capacity = 2
    db_name = "devwebapp"
    db_user = "devadmin"
    db_password = "devpassword123"
    db_instance_class = "db.t3.micro"
}