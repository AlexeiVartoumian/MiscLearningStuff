data "aws_region" "aft_management_region" {}

data "aws_caller_identity" "aft_management_id" {}

# data "aws_ssm_parameter" "aft_request_metadata_table_name" {
#     name = "/aft/resources/ddb/aft-request-metadata-table-name"
# }

# data "aws_dynamodb_table" "aft_request_metadata_table" {
#     name = data.aws_ssm_parameter.aft_request_metadata_table_name.value
# }