# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

# Create a subnet
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "SubnetA"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainGateway"
  }
}

# Create a route table and associate it with the subnet
resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.main.id

  route {
    #cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "MainRouteTable"
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rtable.id
}

# Security group for the EC2 instance
resource "aws_security_group" "example_sg" {
  name        = "example_sg"
  description = "Allow inbound SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0e449927258d45bc4"  # Ensure this is a valid AMI ID for your region
  instance_type = var.instance_type      # Reference the instance_type variable

  key_name      = "task1"  # Replace with your key pair name
  subnet_id     = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.example_sg.id]


  tags = {
    Name = "ExampleInstance"
  }
}
