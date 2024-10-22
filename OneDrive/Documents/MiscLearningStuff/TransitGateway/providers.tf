provider "aws" {
  region = var.region
  # This is your source account configuration
  # No assume role here as this is where we'll create the policy
}
provider "aws" {
  alias  = "account1"
  region = var.region
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.account1_id}:role/AWSControlTowerExecution"
    session_name = "TerraformTGWSession"
  }
}

provider "aws" {
  alias  = "account2"
  region = var.region
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.account2_id}:role/AWSControlTowerExecution"
    session_name = "TerraformVPCSession"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}