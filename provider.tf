terraform {
  cloud {
    organization = "klabstest"
    workspaces {
      project = "seb-demo"
      name = "API-demo1"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  # Configuration options
}