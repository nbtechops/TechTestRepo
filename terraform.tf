variable "desired_region" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "public_key" {
  type = string
}

variable "image_id" {
  type = string
  default = "ami-0e1b4bc489145b24e"
}

provider "aws" {
  region = var.desired_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = {
    app = "techtestapp"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id     = aws_vpc.myvpc.id

  tags = {
    app = "techtestapp"
  }
}

#####################################
#
#  DB Layer
#
######################################

resource "aws_subnet" "db_subnet_1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    app = "techtestapp"
  }
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    app = "techtestapp"
  }
}

resource "aws_route_table" "db_subnet_rt" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }
}

resource "aws_route_table_association" "db_subnet_rta_1" {
    subnet_id = aws_subnet.db_subnet_1.id
    route_table_id = aws_route_table.db_subnet_rt.id
}

resource "aws_route_table_association" "db_subnet_rta_2" {
    subnet_id = aws_subnet.db_subnet_2.id
    route_table_id = aws_route_table.db_subnet_rt.id
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "techtestapp"
  subnet_ids = ["${aws_subnet.db_subnet_1.id}", "${aws_subnet.db_subnet_2.id}"]

  tags = {
    app = "techtestapp"
  }
}

resource "aws_security_group" "db_sg" {

  vpc_id = aws_vpc.myvpc.id
  ingress {
    security_groups = ["${aws_security_group.app_sg.id}"]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    app = "techtestapp"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.3"
  instance_class       = "db.t2.micro"
  name                 = "postgres"
  username             = var.db_user
  password             = var.db_password
  publicly_accessible  = "true"
  skip_final_snapshot  = "true"
  vpc_security_group_ids = [ "${aws_security_group.db_sg.id}" ]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  tags = {
    app = "techtestapp"
  }
}


#######################################
#
# APP LAYER
#
########################################
resource "aws_subnet" "app_subnet_1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    app = "techtestapp"
  }
}

resource "aws_subnet" "app_subnet_2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    app = "techtestapp"
  }
}

resource "aws_route_table" "app_subnet_rt" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

}

resource "aws_route_table_association" "app_subnet_rta_1" {
    subnet_id = "${aws_subnet.app_subnet_1.id}"
    route_table_id = "${aws_route_table.app_subnet_rt.id}"
}

resource "aws_route_table_association" "app_subnet_rta_2" {
    subnet_id = "${aws_subnet.app_subnet_2.id}"
    route_table_id = "${aws_route_table.app_subnet_rt.id}"
}


resource "aws_security_group" "app_sg" {

  vpc_id = aws_vpc.myvpc.id
  ingress {
    security_groups = ["${aws_security_group.elb_sg.id}"]
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    app = "techtestapp"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_instance" "app_1" {
  ami           = var.image_id
  instance_type = "t2.medium"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [ "${aws_security_group.app_sg.id}" ]
  key_name      = "deployer-key"
  subnet_id     = aws_subnet.app_subnet_1.id
  user_data      = <<-EOT
    #!/bin/bash
    echo "export DB_USER=${aws_db_instance.db.username}" > /tmp/init.sh
    echo "export DB_PASSWORD=${aws_db_instance.db.password}" >> /tmp/init.sh
    echo "export DB_HOST=${aws_db_instance.db.address}" >> /tmp/init.sh
    chmod +x /tmp/init.sh
EOT    
#   provisioner "chef" {
#       client_options  = ["chef_license 'accept'"]
#       run_list        = ["cookbook::recipe"]
#   }

  tags = {
    app = "techtestapp"
  }
}

resource "aws_instance" "app_2" {
  ami           = var.image_id
  instance_type = "t2.medium"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [ "${aws_security_group.app_sg.id}" ]
  key_name      = "deployer-key"
  subnet_id     = aws_subnet.app_subnet_2.id
  user_data      = <<-EOT
    #!/bin/bash
    echo "export DB_USER=${aws_db_instance.db.username}" > /tmp/init.sh
    echo "export DB_PASSWORD=${aws_db_instance.db.password}" >> /tmp/init.sh
    echo "export DB_HOST=${aws_db_instance.db.address}" >> /tmp/init.sh
    chmod +x /tmp/init.sh
EOT    
#   provisioner "chef" {
#       client_options  = ["chef_license 'accept'"]
#       run_list        = ["cookbook::recipe"]
#   }

  tags = {
    app = "techtestapp"
  }
}

#######################################
#
# ELB LAYER
#
########################################

# resource "aws_subnet" "elb_subnet" {
#   vpc_id     = aws_vpc.myvpc.id
#   cidr_block = "10.0.14.0/24"

#   tags = {
#     app = "techtestapp"
#   }
# }

resource "aws_security_group" "elb_sg" {

  vpc_id = aws_vpc.myvpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    app = "techtestapp"
  }
}

resource "aws_elb" "elb" {
  name               = "techtest-elb"
  security_groups    = ["${aws_security_group.elb_sg.id}"]
  subnets            = [ "${aws_subnet.app_subnet_1.id}", "${aws_subnet.app_subnet_2.id}" ]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/"
    interval            = 30
  }

  instances                   = ["${aws_instance.app_1.id}", "${aws_instance.app_2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    app = "techtestapp"
  }

}

output "db_hostname" {
  value = "${aws_db_instance.db.address}"
}

output "ec2_url_1" {
  value = "${aws_instance.app_1.public_dns}:3000"
}

output "ec2_url_2" {
  value = "${aws_instance.app_2.public_dns}:3000"
}

output "elb_url" {
  value = "${aws_elb.elb.dns_name}:3000"
}

output "jenkins_url_1" {
  value = "${aws_instance.app_1.public_dns}:8080"
}

output "jenkins_url_2" {
  value = "${aws_instance.app_2.public_dns}:8080"
}