# output "cluster_endpoint" {
#   description = "Endpoint for EKS control plane"
#   value       = aws_eks_cluster.this.endpoint #module.eks.cluster_endpoint
# }

# output "cluster_name" {
#   description = "EKS cluster name"
#   value       = aws_eks_cluster.this.endpoint #module.eks.cluster_name
# }

# output "cluster_arn" {
#   description = "EKS cluster ARN"
#   value       = aws_eks_cluster.this.endpoint #module.eks.cluster_arn
# }

# output "vpc_id" {
#   description = "VPC ID"
#   value       = module.vpc.vpc_id
# }

# output "developer_readonly_access_key" {
#   description = "Access key for readonly developer user"
#   value       = aws_iam_access_key.developer_readonly.id
# }

# output "developer_readonly_secret_key" {
#   description = "Secret key for readonly developer user"
#   value       = aws_iam_access_key.developer_readonly.secret
#   sensitive   = true
# }


# output "orders_db_endpoint" {
#   description = "RDS PostgreSQL endpoint for orders service"
#   value       = var.enable_managed_persistence ? aws_db_instance.orders_postgres[0].endpoint : null
# }

# output "catalog_db_endpoint" {
#   description = "RDS MySQL endpoint for catalog service"
#   value       = var.enable_managed_persistence ? aws_db_instance.catalog_mysql[0].endpoint : null
# }

# output "carts_dynamodb_table" {
#   description = "DynamoDB table name for carts service"
#   value       = var.enable_managed_persistence ? aws_dynamodb_table.carts[0].name : null
# }


# --- EKS Cluster Outputs ---
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# --- Node Group Outputs ---
output "node_group_name" {
  description = "EKS node group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = aws_eks_node_group.main.arn
}

output "node_role_arn" {
  description = "IAM role ARN used by worker nodes"
  value       = aws_iam_role.eks_node_role.arn
}

# --- IAM Outputs ---
output "developer_readonly_access_key" {
  description = "Access key for readonly developer user"
  value       = aws_iam_access_key.developer_readonly.id
}

output "developer_readonly_secret_key" {
  description = "Secret key for readonly developer user"
  value       = aws_iam_access_key.developer_readonly.secret
  sensitive   = true
}

# --- Database Outputs ---
output "orders_db_endpoint" {
  description = "RDS PostgreSQL endpoint for orders service"
  value       = var.enable_managed_persistence ? aws_db_instance.orders_postgres[0].endpoint : null
}

output "catalog_db_endpoint" {
  description = "RDS MySQL endpoint for catalog service"
  value       = var.enable_managed_persistence ? aws_db_instance.catalog_mysql[0].endpoint : null
}

output "carts_dynamodb_table" {
  description = "DynamoDB table name for carts service"
  value       = var.enable_managed_persistence ? aws_dynamodb_table.carts.name : null
}
