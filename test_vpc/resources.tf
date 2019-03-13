# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name   = "vpctestkeypair"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_key_pair" "example-key-pair" {
  key_name   = "${var.identity}-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# Define webserver inside the public subnet
resource "aws_instance" "wb" {
  ami                         = "${var.ami}"
  instance_type               = "t1.micro"
  key_name                    = "${aws_key_pair.example-key-pair.id}"
  subnet_id                   = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.sgweb.id}"]
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${file("install.sh")}"

  provisioner "remote-exec" {
    inline = [
      "hostname",
    ]
  }

  connection {
    user        = "ec2-user"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  tags {
    Name = "webserver"
  }
}

# Define database inside the private subnet
resource "aws_instance" "db" {
  ami                    = "${var.ami}"
  instance_type          = "t1.micro"
  key_name               = "${aws_key_pair.default.id}"
  subnet_id              = "${aws_subnet.private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  source_dest_check      = false

  tags {
    Name = "database"
  }
}
