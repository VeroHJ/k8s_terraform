resource "aws_key_pair" "ec2_ssh_key" {
  key_name = var.ssh_key_name
  public_key = file(var.ssh_key_path)
  tags = {"Name" = "ec2_ssh_key"}
}

resource "aws_security_group" "ec2_security_group" {
  name = var.security_group_name
  description = "Allow SSH and HTTP traffic"
  vpc_id = aws_vpc.ec2_vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    description = "HTTP80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    description = "6443 TCP" //for k8s
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    description = "6443 UDP"
    from_port = 6443
    to_port = 6443
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    description = "30002 TCP"
    from_port = 30002
    to_port = 30002
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    description = "10250 k8s containers"
    from_port = 10250
    to_port = 10250
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {"Name" = "ec2_security_group"}
}

/*resource "aws_iam_role" "ec2_role" {
  name = var.ec2_iam_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "policyAttachment" {
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryFullAccess.arn
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.iam_instance_profile_name
  role = var.ec2_iam_role_name
}*/

resource "aws_instance" "vh_k8s_master" {
  subnet_id = aws_subnet.ec2_subnet.id
  ami = var.ami
  instance_type = var.instance_type_master
  key_name = aws_key_pair.ec2_ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  tags = {"Name" = "vh_k8s_master"}
  private_ip = "10.0.1.7"
  associate_public_ip_address = true
  //iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
}

resource "aws_instance" "vh_k8s_worker" {
  subnet_id = aws_subnet.ec2_subnet.id
  ami = var.ami
  instance_type = var.instance_type_slave
  key_name = aws_key_pair.ec2_ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  tags = {"Name" = "vh_k8s_worker"}
  private_ip = "10.0.1.8"
  associate_public_ip_address = true
  //iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
}

//resource "aws_instance" "vh_k8s_node_2" {
//  subnet_id = aws_subnet.ec2_subnet.id
//  ami = var.ami
//  instance_type = var.instance_type_slave
//  key_name = aws_key_pair.ec2_ssh_key.key_name
//  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
//  tags = {"Name" = "vh_k8s_node_2", "Backup" = "true"}
//  private_ip = "10.0.1.9"
//  associate_public_ip_address = true
//  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
//}

