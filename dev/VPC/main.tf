##### VPC #####
resource "aws_vpc" "narean" {
  cidr_block = "172.5.0.0/16"

  tags = {
    Name = "VPC"
  }
}

##### Internet Gateway #####
resource "aws_internet_gateway" "narean_internet_gateway" {
  vpc_id = aws_vpc.narean.id

  tags = {
    Name = "Internet Gateway"
  }
}

##### AZ #####
variable "availability_zones" {
  description = "Availability Zones"
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

##### Subnet #####
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.narean.id
  cidr_block        = "172.5.${count.index + 1}.0/24"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.narean.id
  cidr_block        = "172.5.${count.index + 4}.0/24"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

##### Route Table #####
resource "aws_route_table" "narean_rt" {
  vpc_id = aws_vpc.narean.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.narean_internet_gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

##### Route Table connect #####
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.narean_rt.id
}

##### Security Group #####
resource "aws_security_group" "narean_sg" {
  name   = "narean_sg"
  vpc_id = aws_vpc.narean.id

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "narean Security Group"
  }
}