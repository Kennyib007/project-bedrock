# Fetch AWS account details
data "aws_caller_identity" "current" {}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = aws_eks_node_group.main.node_group_name
}
