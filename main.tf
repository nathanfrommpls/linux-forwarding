# AWS Account and Network Infrastructure

resource "aws_vpc" "linux-fowarding" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "linux-fowarding"
  }
}

resource "aws_internet_gateway" "linux-fowarding" {
  vpc_id = aws_vpc.linux-fowarding.id

  tags = {
    Name = "linux-fowarding"
  }
}

resource "aws_subnet" "linux-fowarding1" {
  vpc_id                  = aws_vpc.linux-fowarding.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.first_az

  depends_on = [aws_internet_gateway.linux-fowarding]

  tags = {
    Name = "linux-fowarding"
  }
}

resource "aws_subnet" "linux-fowarding2" {
  vpc_id                  = aws_vpc.linux-fowarding.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.second_az

  depends_on = [aws_internet_gateway.linux-fowarding]

  tags = {
    Name = "linux-fowarding"
  }
}

resource "aws_route_table" "linux-fowarding" {
  vpc_id = aws_vpc.linux-fowarding.id

  tags = {
    Name = "linux-fowarding"
  }
}

resource "aws_route" "linux-fowardingegress" {
  route_table_id         = aws_route_table.linux-fowarding.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.linux-fowarding.id
  depends_on             = [aws_route_table.linux-fowarding]
}

resource "aws_route_table_association" "linux-fowarding1" {
  subnet_id      = aws_subnet.linux-fowarding1.id
  route_table_id = aws_route_table.linux-fowarding.id
}

resource "aws_route_table_association" "linux-fowarding2" {
  subnet_id      = aws_subnet.linux-fowarding2.id
  route_table_id = aws_route_table.linux-fowarding.id
}


resource "aws_security_group" "linux-fowarding" {
  name        = "linux-fowarding"
  description = "Security group for linux-fowarding terraform deployment."
  vpc_id      = aws_vpc.linux-fowarding.id

  tags = {
    Name = "linux-fowarding"
  }
}

resource "aws_security_group_rule" "linux-fowarding-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.linux-fowarding.id
}

resource "aws_security_group_rule" "linux-fowarding-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.linux-fowarding.id
}

# AWS Instances & Associated Infrastructure

resource "aws_instance" "linux-fowarding-forwarder" {
  count                  = var.first_az_server_count
  ami                    = var.ami_image
  instance_type          = var.ec2_type
  subnet_id              = aws_subnet.linux-fowarding1.id
  vpc_security_group_ids = [aws_security_group.linux-fowarding.id]
  depends_on             = [aws_internet_gateway.linux-fowarding]
  key_name               = var.sshkeypair
  user_data              = file("forwarder.sh")

  tags = {
    Name = "forwarder"
  }
}

resource "aws_instance" "linux-fowarding-httpd" {
  count                  = var.second_az_server_count
  ami                    = var.ami_image
  instance_type          = var.ec2_type
  subnet_id              = aws_subnet.linux-fowarding2.id
  vpc_security_group_ids = [aws_security_group.linux-fowarding.id]
  depends_on             = [aws_internet_gateway.linux-fowarding]
  key_name               = var.sshkeypair
  user_data              = file("httpd.sh")

  tags = {
    Name = "web server"
  }
}

# Exposing individual systems for testing purposes.

resource "aws_eip" "linux-fowardingfirst" {
  count                     = var.first_az_server_count
  vpc                       = true
  instance                  = aws_instance.linux-fowarding-forwarder.id
  associate_with_private_ip = aws_instance.linux-fowarding-forwarder.private_ip
  depends_on                = [aws_internet_gateway.linux-fowarding]

  tags = {
    Name = "fowarder"
  }
}
