# ------------------------- #
# Secret Manager For Twingate
# ------------------------- #
resource "aws_secretsmanager_secret" "twingate" {
  name        = "twingate/credentials"
  description = "Credentials for Twingate"
}

resource "aws_secretsmanager_secret_version" "twingate_version" {
  secret_id     = aws_secretsmanager_secret.twingate.id
  secret_string = jsonencode({
    TWINGATE_ACCESS_TOKEN = "dummy-access-token",
    TWINGATE_NETWORK      = "dummy-network"
  })
}

data "aws_secretsmanager_secret" "twingate" {
  name = aws_secretsmanager_secret.twingate.name
}

data "aws_secretsmanager_secret_version" "twingate_version" {
  secret_id = data.aws_secretsmanager_secret.twingate.id
}
