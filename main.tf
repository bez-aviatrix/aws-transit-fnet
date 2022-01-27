terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aviatrix" {
}

provider "aws" {
  region = var.region
}

resource "random_id" "this" {
  byte_length = 8
}
resource "aws_s3_bucket" "this" {
  bucket = "bootstrap-${random_id.this.hex}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "prefixes" {
  for_each = toset(var.bprefixes)

  bucket  = aws_s3_bucket.this.id
  key     = each.value
  content = "/dev/null"
}

resource "aws_s3_bucket_object" "bootstrap" {
  bucket = aws_s3_bucket.this.id
  key    = "config/bootstrap.xml"
  source = "./pan-fw-running-config.xml"
}

resource "aws_s3_bucket_object" "init_cfg" {
  bucket = aws_s3_bucket.this.id
  key    = "config/init-cfg.txt"
  source = "./init-cfg.txt"
}

resource "aws_iam_role" "this" {
  name = "panbootstraprole-${random_id.this.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = "panbootstraprolepolicy-${random_id.this.hex}"
  role = aws_iam_role.this.id

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "panbootstraprole-${random_id.this.hex}"
  role = aws_iam_role.this.name
  path = "/"
}

module "aws-tfnet" {
  source  = "terraform-aviatrix-modules/aws-transit-firenet/aviatrix"
  version = "4.0.3"
  name    = var.name
  cidr    = var.cidr
  region  = var.region
  account = var.account
  prefix  = false

  egress_enabled                       = false
  keep_alive_via_lan_interface_enabled = true

  fw_amount               = 2
  firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  bootstrap_bucket_name_1 = aws_s3_bucket.this.bucket
  iam_role_1              = aws_iam_role.this.name
  tags                    = var.tags
}

module "aws_spoke" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "4.0.3"
  count   = 2

  name       = var.sp_name[count.index]
  cidr       = cidrsubnet(var.sp_cidr, 2, count.index)
  region     = var.sp_region[count.index]
  account    = var.account
  transit_gw = module.aws-tfnet.transit_gateway.gw_name
  prefix     = false
  tags       = var.tags
}