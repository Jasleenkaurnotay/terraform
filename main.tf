module "vpc_mod" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  private_cidr = var.private_cidr
  rds_cidr     = var.rds_cidr
  public_cidr  = var.public_cidr
  environment  = var.environment
}

module "security_groups_mod" {
  source       = "./modules/security_groups"
  vpc_id       = module.vpc_mod.vpc_id
  project_name = var.project_name
  environment  = var.environment
}

module "alb_mod" {
  source        = "./modules/alb"
  project_name  = var.project_name
  environment   = var.environment
  alb_sg_id     = module.security_groups_mod.alb_sg_id
  public_subnet = module.vpc_mod.public_subnet
  vpc_id        = module.vpc_mod.vpc_id
}