module "network" {
  source = "./modules/network"

  name = local.name

  vpc_cidr           = var.vpc_cidr
  availability_zones = local.availability_zones

  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = local.name
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  tags = local.common_tags
}

module "cicd" {
  source = "./cicd"

  project_name = var.project_name
  environment  = var.environment

  repository_owner  = var.repository_owner
  repository_name   = var.repository_name
  repository_branch = var.repository_branch

  connection_arn = var.connection_arn

  tags = local.common_tags
}