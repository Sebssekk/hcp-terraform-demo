terraform {
  ### ONLY REQUIRED FOR CLI DRIVEN APPROACH ###
  cloud {
    organization = "<ORG NAME>"
    workspaces {
      project = "<PROJECT_NAME>"
      name = "<WORKSPACE NAME>"
    }
  }
  #############################################
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