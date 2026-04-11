#region
variable "aws_region" {
  type = string
  default = "ap-south-1"
  
}

#vpc cidr
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

#enable dns hostnames
variable "enable_dns_hostnames" { 
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
#enable dns support
variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true  
}
#common tags
variable "common_tags" {  
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Project  = "Infrastructure"
    Team      = "DevOps"
    Managedby = "Terraform"
  }
}

variable "project" {
  type        = string
  default     = "amazon"
  description = "Project name for tagging"
}

variable "environment" {
  type        = string
  default     = "production"
}

variable "public_subnet_cidrs" {
  description = "CIDR block for the public subnet"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  
}

variable "map_public_ip_on_launch" {
 type = bool
 default = true 
}

variable "private_subnet_cidrs" {
  description = "CIDR block for the private subnet"
  type        = list(string)
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]

}