# ------------------------- #
# ECS Cluster
# ------------------------- #
resource "aws_ecs_cluster" "twingate_cluster" {
  count = var.is_twingate ? 1 : 0
  name = "${var.project}-ecs-cluster-${var.env}"
}

# ------------------------- #
# ECS Task Definition
# ------------------------- #
resource "aws_ecs_task_definition" "twingate_task" {
  count = var.is_twingate ? 1 : 0
  family                   = "twingate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "twingate-connector"
      image     = "twingate/connector:latest"
      essential = true
      environment = []
      secrets = [
        {
          name      = "TWINGATE_NETWORK"
          valueFrom = "${data.aws_secretsmanager_secret_version.twingate_version.arn}:TWINGATE_NETWORK"
        },
        {
          name      = "TWINGATE_ACCESS_TOKEN"
          valueFrom = "${data.aws_secretsmanager_secret_version.twingate_version.arn}:TWINGATE_ACCESS_TOKEN"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/twingate"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ------------------------- #
# ECS Service
# ------------------------- #
resource "aws_ecs_service" "twingate_service" {
  count = var.is_twingate ? 1 : 0
  name            = "twingate-service"
  cluster         = aws_ecs_cluster.twingate_cluster[count.index].id
  task_definition = aws_ecs_task_definition.twingate_task[count.index].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.main["public_1a"].id]
    security_groups = [aws_security_group.ecs[count.index].id]
    assign_public_ip = true
  }
}
