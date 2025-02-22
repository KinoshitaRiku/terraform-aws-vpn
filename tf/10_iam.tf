resource "aws_iam_role" "ssm_role" {
  name               = "${var.project}-ssm-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "${var.project}-ssm-attachment-${var.env}"
  roles      = [aws_iam_role.ssm_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.project}-instance-profile-${var.env}"
  role = aws_iam_role.ssm_role.name
}