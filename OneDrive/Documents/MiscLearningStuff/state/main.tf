provider "aws" {
    region = var.web_region
    access_key = var.access_key
    secret_key = var.secret_key
}

data "aws_servicecatalog_portfolio" "portfolio" {
     id = "port-dzzghuqbtqsdo"
}

output "existing_provider_name"{
    value = data.aws_servicecatalog_portfolio.portfolio.provider_name
}

resource "aws_servicecatalog_portfolio" "portfolio" {
    name = "My App Portfolio"
    description = "my demo portfolio"
    provider_name = data.aws_servicecatalog_portfolio.portfolio.provider_name
}
 

module "template" {
    source = ".//module/template"
}
resource "aws_s3_bucket" "template_bucket" {
  bucket = "your-unique-bucket-name-for-templates-${random_string.bucket_suffix.result}"
}

# Generate random suffix for bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "template_bucket" {
  bucket = aws_s3_bucket.template_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "template" {
  bucket  = aws_s3_bucket.template_bucket.id
  key     = "template.json"
  content = module.template.template_content
  etag    = md5(module.template.template_content)
}

resource "aws_servicecatalog_product" "example" {
    name ="example"
    owner = "example-owner"
    type = "CLOUD_FORMATION_TEMPLATE"

    provisioning_artifact_parameters {
        name = "v1.0"
        description = "Initial version"
        type        = "CLOUD_FORMATION_TEMPLATE"
        template_url = "https://${aws_s3_bucket.template_bucket.bucket_regional_domain_name}/${aws_s3_object.template.key}"
        
    }
    depends_on = [
        aws_servicecatalog_portfolio.portfolio
    ]
}


resource "aws_servicecatalog_product_portfolio_association" "example" {
    portfolio_id = aws_servicecatalog_portfolio.portfolio.id
    product_id = aws_servicecatalog_product.example.id
}

# data "aws_servicecatalog_portfolio" "new_portfolio"{

#   }


# resource "aws_servicecatalog_product" "example" {
#     name = ""
# }