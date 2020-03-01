provider "aws" {}
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.3"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "postgres"
  password             = "changeme"
}
resource "aws_instance" "web" {
  ami           = "ami-00240f6f25c5a080b"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"

  tags = {
    Name = "HelloWorld"
  }
}

output "db_hostname" {
  value = "${aws_db_instance.example.address}"
}

output "web_hostname" {
  value = "${aws_instance.web.public_dns}"
}