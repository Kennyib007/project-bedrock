# SGs
resource "aws_security_group" "rds_postgres" {
  count       = var.enable_managed_persistence ? 1 : 0
  name        = "${var.project_name}-rds-postgres"
  description = "Allow Postgres from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_mysql" {
  count       = var.enable_managed_persistence ? 1 : 0
  name        = "${var.project_name}-rds-mysql"
  description = "Allow MySQL from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ingress from nodes SG 
resource "aws_security_group_rule" "rds_allow_postgres_from_eks_nodes" {
  count                    = var.enable_managed_persistence ? 1 : 0
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  security_group_id        = aws_security_group.rds_postgres[0].id
}

resource "aws_security_group_rule" "rds_allow_mysql_from_eks_nodes" {
  count                    = var.enable_managed_persistence ? 1 : 0
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  security_group_id        = aws_security_group.rds_mysql[0].id
}

# Subnet group (private subnets)
resource "aws_db_subnet_group" "orders" {
  count      = var.enable_managed_persistence ? 1 : 0
  name       = "${var.project_name}-orders-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# Postgres
resource "aws_db_instance" "orders_postgres" {
  count = var.enable_managed_persistence ? 1 : 0

  identifier     = "${var.project_name}-orders-db"
  engine         = "postgres"
  engine_version = "15.10"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = "orders"
  username = "orders_admin"
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds_postgres[0].id]
  db_subnet_group_name   = aws_db_subnet_group.orders[0].name

  skip_final_snapshot = true
}

# MySQL 
resource "aws_db_instance" "catalog_mysql" {
  count = var.enable_managed_persistence ? 1 : 0

  identifier     = "${var.project_name}-catalog-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = "catalog"
  username = "catalog_admin"
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds_mysql[0].id]
  db_subnet_group_name   = aws_db_subnet_group.orders[0].name

  skip_final_snapshot = true
}

# DynamoDB
resource "aws_dynamodb_table" "carts" {
  name         = "project-bedrock-carts"
  billing_mode = "PAY_PER_REQUEST"

  # Primary key
  hash_key = "cartId"

  attribute {
    name = "cartId"
    type = "S"
  }

  # Define the attribute for the GSI
  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
  }

  tags = {
    Environment = "prod"
    Service     = "carts"
  }
}


