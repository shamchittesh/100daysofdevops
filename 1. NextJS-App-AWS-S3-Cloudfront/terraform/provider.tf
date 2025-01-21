terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}


terraform { 
  cloud { 
    
    organization = "Perso_AWS" 

    workspaces { 
      name = "nextjs-s3-cloudfront" 
    } 
  } 
}