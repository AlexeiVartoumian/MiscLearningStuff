provider "aws" {
    region = var.web_region
    access_key = var.access_key
    secret_key = var.secret_key
}


terraform {
    #backend where state files are stored
    backend "s3" {

        bucket = "somebuckethaha"
        region = "eu-west-2"
        key = "tfstate"
        access_key = #var.access_key
        secret_key = #var.secret_key
        #encrypt = true
    }
}

data "archive_file" "screenshot_service_zip"{
    type = "zip"
    #source_dir = "C:\\Users\\alexv\\OneDrive\\Documents\\MiscLearningStuff\\screnshoot-service\\lambda"
    source_dir = "lambda"
    output_path  ="/screenshot-service.zip"
}

data "archive_file" "screenshot_service_layer_zip" {
    type = "zip"
    #source_file = "C:\\Users\\alexv\\OneDrive\\Documents\\MiscLearningStuff\\screnshoot-service"
    source_dir = "chromedriver_layer"
    output_path = "/chromedriver_lambda_layer.zip"
}

#

