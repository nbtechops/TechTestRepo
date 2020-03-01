provider "aws" {}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_subnet" "app" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.3.0/24"
}

resource "aws_subnet" "db" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"
}

resource "aws_security_group" "sg_open" {
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8000
    to_port     = 9000
    protocol    = "tcp"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.3"
  instance_class       = "db.t2.micro"
  name                 = "postgres"
  username             = "postgres"
  password             = "changeme"
  publicly_accessible  = "true"
  skip_final_snapshot  = "true"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCFQUg/mjNee8vwGl1+VZA452NNblzQ6/MHKv79cR4JIqsTeosPdsXPv/2iAzIdCJGWQ5WdZkvo+lrAu2MAtSidRvNc2928vCZqHX/NBkFTskBtHlAalwIvlvuWe4QNC64zTReVafbTjP83/Y7B1VgYOvMqqvOJxeGyhpCtyyHoPUX8lYn+GnR2X2ogfnYt/qPwnZ8VhCo9p9ir64seK58My+WM2vgNGofAnYex6B8Budit+J1o1U5GH5EHvoUKjfksCYTw8d3cmIWFD0JTrqWSXaSg2Zl+nX+uYbH0m2ha3xqV3CnFozAHepkIBKJjk81ApENXdnwYBJLuFX1/JOWx"
}

resource "aws_instance" "web" {
  ami           = "ami-0d0197bb676e60c74"
  instance_type = "t2.medium"
  associate_public_ip_address = "true"
  key_name      = "deployer-key"
  user_data      = "echo DB_USER=postgres >> /etc/environment && echo DB_PASSWORD=changeme >> /etc/environment && docker run -itd --rm --name techtestapp-init -p 3000:3000 -e VTT_DBUSER=postgres -e VTT_DBPASSWORD=changeme -e VTT_DBNAME=postgres -e VTT_DBPORT=5432 -e VTT_DBHOST=database-1.c056joafnb52.ap-southeast-2.rds.amazonaws.com -e VTT_LISTENHOST=0.0.0.0 -e VTT_LISTENPORT=3000 techtestapp:latest updatedb -s"
  
#   provisioner "chef" {
#       client_options  = ["chef_license 'accept'"]
#       run_list        = ["cookbook::recipe"]
#   }
}

resource "aws_elb" "elb" {
  name               = "my-terraform-elb"
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = ["${aws_instance.web.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}

output "db_hostname" {
  value = "${aws_db_instance.db.address}"
}

output "web_hostname" {
  value = "${aws_instance.web.public_dns}"
}