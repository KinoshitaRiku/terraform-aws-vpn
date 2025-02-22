####################
# SG EC2
####################
resource "aws_security_group" "ec2" {
  name   = "${var.project}-ecs-sg-${var.env}"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ec2_1194" {
  security_group_id = aws_security_group.ec2.id
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}