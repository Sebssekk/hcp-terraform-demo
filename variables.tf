variable "ec2_type" {
  description = "EC2 family type"
  type = string
  default = "t3.small"
  
}
variable "name_prefix" {
  description = "Prefix Name pr every resources"
  type = string
}

variable "tf_vpc__cidr_block" {
  description = "The CIDR of infrastructure VPC"
  type =  string
  default = "192.168.0.0/16"
}

variable "tf_pub_subnet__cidr_block" {
  description = "The CIDR of Public Subnet"
  type =  string
  default = "192.168.1.0/24"
}

variable "ami_name_filter" {
  description = "Filter for get AMI default Ubuntu 25.04"
  type = string
  default = "ubuntu/images/hvm-ssd-gp3/ubuntu-plucky*"
}

variable "public_key_material" {
  description = "SSH Public Key content"
  type = string
}