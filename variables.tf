variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "my_ip" {
  type        = string
  default     = "0.0.0.0/0"
  description = "IP address allowed for SSH access"
}
