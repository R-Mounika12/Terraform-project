resource "aws_vpc" "mvpc" {
    cidr_block = var.cidr_block
}

resource "aws_subnet" "pubSub1" {
  vpc_id = aws_vpc.mvpc.id
  availability_zone = "eu-north-1a"
  cidr_block = var.pubsub1Cidr
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pubSub2" {
  vpc_id = aws_vpc.mvpc.id
  availability_zone = "eu-north-1b"
  cidr_block = var.pubsub2Cidr
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "mig" {
  vpc_id = aws_vpc.mvpc.id
}

resource "aws_route_table" "mrt" {
  vpc_id = aws_vpc.mvpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mig.id
  }
}

resource "aws_route_table_association" "mrta1" {
  route_table_id = aws_route_table.mrt.id
  subnet_id = aws_subnet.pubSub1.id
}

resource "aws_route_table_association" "mrta2" {
  route_table_id = aws_route_table.mrt.id
  subnet_id = aws_subnet.pubSub2.id
}

resource "aws_security_group" "msg" {
  name        = "websg"
  vpc_id      = aws_vpc.mvpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ipv4Access]
  }

    ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.ipv4Access]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mwebser1" {
  ami = "ami-0fe8bec493a81c7da"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.msg.id]
  subnet_id = aws_subnet.pubSub1.id
  user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "mwebser2" {
  ami = "ami-0fe8bec493a81c7da"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.msg.id]
  subnet_id = aws_subnet.pubSub2.id
  user_data = base64encode(file("userdata1.sh"))
}
