
provider "aws" {
    region = var.aws_region
}


module "networking" {
    source = "./modules/networking"
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    availability_zones = var.availability_zones
}

module "compute" {
    source = "./modules/compute"

    vpc_id = module.networking.vpc_id
    public_subnet_ids = module.networking.public_subnet_ids
    web_server_sg_id = module.security.web_server_sg_id
    instance_type = var.instance_type
    key_name = var.key_name
    max_size = var.max_size
    min_size = var.min_size
    desired_capacity = var.desired_capacity
    health_check_grace_period = var.health_check_grace_period
}

module "security" {
    source = "./modules/security"
    vpc_id = module.networking.vpc_id
}

module "database" {
    source = "./modules/database"
    vpc_id = module.networking.vpc_id
    private_subnet_ids = module.networking.private_subnet_ids
    db_subnet_group_name = var.db_subnet_group_name
    db_name = var.db_name
    db_user = var.db_user
    db_password  = var.db_password
    db_instance_class = var.db_instance_class
    db_sg_id = module.security.db_sg_id
}
