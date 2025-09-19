resource "aws_instance" "nginxserver" {
  ami                         = "ami-043339ea831b48099"
  instance_type               = "t3.nano"
  subnet_id                   = aws_subnet.public-subnet.id
  vpc_security_group_ids      = [aws_security_group.nginx-sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
        #!/bin/bash
        sudo yum install nginx -y
        sudo systemctl start nginx
        EOF

  tags = {
    Name = "NginxServer"
  }
}
