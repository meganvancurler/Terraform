variable "instance1_name" {
  description = "The name of the first EC2 instance"
  type        = string
}

variable "instance2_name" {
  description = "The name of the second EC2 instance"
  type        = string
}

variable "region" {
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
