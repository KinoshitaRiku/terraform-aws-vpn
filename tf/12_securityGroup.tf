# ------------------------- #
# Security Group EC2
# ------------------------- #
resource "aws_security_group" "ec2" {
  count = var.is_openvpn ? 1 : 0
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
  count = var.is_openvpn ? 1 : 0
  security_group_id = aws_security_group.ec2[count.index].id
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ------------------------- #
# Security Group ECS
# ------------------------- #
resource "aws_security_group" "ecs" {
  count = var.is_twingate ? 1 : 0
  name   = "${var.project}-ecs-sg-${var.env}"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ecs_1194" {
  count = var.is_twingate ? 1 : 0
  security_group_id = aws_security_group.ecs[count.index].id
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}
