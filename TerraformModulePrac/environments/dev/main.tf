terraform{

    backend "s3" {
        bucket = "my-terraform-state-bucket"
        key = "dev/webapp/terraform.tfstate"
        region = "eu-west-2"
    }
}

module "webapp" {
  source = "../.."  # This points to the root of your project

  # Pass all the variables needed by the root module
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  instance_type        = var.instance_type
  key_name             = var.key_name
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  db_name              = var.db_name
  db_username          = var.db_username
  db_instance_class    = var.db_instance_class
  environment          = "dev"
}


