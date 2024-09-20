
terraform{
    backend "s3"{
        bucket = "somebuckethaha"
        key = "stateCiCd"
        region = "eu-west-2"
        dynamodb_table = "backend"
    }
}