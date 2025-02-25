terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

resource "random_pet" "valheim" {
  keepers = {
    valheim = var.world_name
  }
}

provider "aws" {
  region = var.region
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

locals {
  world  = "valheim-${random_pet.valheim.id}"
  vpc_id = var.vpc_id == "" ? aws_default_vpc.default.id : var.vpc_id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

resource "aws_s3_bucket" "backups" {
  bucket_prefix = "valheim-backup-${lower(var.world_name)}"
}
