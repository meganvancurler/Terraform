provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnetA"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnetB"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "PrivateSubnetA"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "PrivateSubnetB"
  }
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

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

  tags = {
    Name = "WebServerSG"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "RDSSG"
  }
}

resource "aws_instance" "web1" {
  ami           = "ami-03fe41d91fd55ff15" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_a.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = var.instance1_name
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-03fe41d91fd55ff15" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_b.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = var.instance2_name
  }
}

resource "aws_db_instance" "mydb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "verysecurepassword"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.mydb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "MyDB"
  }
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "MyDBSubnet


