# ------------------------- #
# EC2
# ------------------------- #
resource "aws_instance" "vpn" {
  count = var.is_openvpn ? 1 : 0
  ami           = var.ec2_ami
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  subnet_id = aws_subnet.main["public_1a"].id

  tags = {
    Name = "${var.project}-ec2-${var.env}"
  }

  # セキュリティグループを適用
  vpc_security_group_ids = [aws_security_group.ec2[count.index].id]
  user_data = <<EOF
    #!/bin/bash
    sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
  EOF
}

resource "aws_eip" "ec2" {
  count = var.is_openvpn ? 1 : 0
  domain = "vpc"
  instance = aws_instance.vpn[count.index].id
  tags = {
    Name = "${var.project}-eip-ec2-${var.env}"
  }
}
