variable "bprefixes" {
  description = "The aws s3 prefixes comprising the bootstrap package"
  default = [
    "config/",
    "content/",
    "software/",
    "license/"
  ]
}

variable "region" {
  description = "AWS region for this deployment"
  default     = "us-east-1"
}

variable "cidr" {
  description = "VPC CIDR for the firenet"
  default     = "10.157.0.0/16"
}

variable "account" {
  description = "Aviatrix AWS account"
  default     = ""
}

variable "name" {
  description = "Name tag used for both gateway and firewalls"
  default     = "austin"
}

variable "sp_cidr" {
  description = "CIDR for AWS Spoke"
  default     = "172.20.0.0/16"
}

variable "sp_region" {
  description = "Region for AWS Spoke"
  default     = ["us-east-2", "us-west-2"]
}

variable "sp_name" {
  description = "Spoke gateway name prefix"
  default     = ["dallas", "portland"]
}

variable "tags" {
  description = "Resource tag values as a map"
  default     = { "owner" : "babebe", "env" : "testing" }
}