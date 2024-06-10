resource "aws_s3_bucket" "screenshot_bucket"{
    bucket = "somebuckethaha"
    force_destroy = true
    acl = "public-read"

    versioning {
        enabled = false
    }  
    
}