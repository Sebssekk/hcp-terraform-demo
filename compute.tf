data "aws_ami" "instance_ami"{
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["${var.ami_name_filter}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "tf_ssh_key" {
  key_name   = "${var.name_prefix}-sshkey"
  public_key = var.public_key_material
}
resource "aws_instance" "tf_instance" {
  ami           = data.aws_ami.instance_ami.id
  key_name      = aws_key_pair.tf_ssh_key.key_name 
  instance_type = var.ec2_type
  subnet_id     = aws_subnet.tf_pub_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
     aws_security_group.allow_ssh.id
     ]

  tags = {
    Name = "${var.name_prefix}-instance"
  }
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.name_prefix}-allow_ssh"
  }
  
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0" 
  ip_protocol       = "tcp"
  # PORT RANGE
  from_port         = 22 
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}