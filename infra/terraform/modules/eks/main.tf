module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true

  eks_managed_node_groups = {
    application = {
      name = "application"

      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      capacity_type = "ON_DEMAND"

      disk_size = 30
    }
  }

  tags = var.tags
}