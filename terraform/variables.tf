variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "ami" {
  default = "ami-042e8287309f5df03"
}

variable "instance_type_master" {
  default = "t3.small"
 // default = "t2.micro"
}

variable "instance_type_slave" {
  default = "t2.micro"
}

variable "ssh_key_path" {
  default = "../ansible/ssh/id_rsa.pub"
}

variable "ssh_key_name" {
  default = "ec2-ssh-key"
}

variable "security_group_name" {
  default = "ec2-security-group"
}

variable "ec2_iam_role_name" {
  default = "ec2_iam_role"
}

variable "iam_role_policy_name" {
  default = "ec2_iam_role_policy"
}

variable "iam_instance_profile_name" {
  default = "ec_instance_profile"
}
