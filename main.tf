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

module "ecs_mod" {
  source          = "./modules/ecs"
  aws_region      = var.aws_region
  project_name    = var.project_name
  environment     = var.environment
  alb_sg_id       = module.security_groups_mod.alb_sg_id
  private_subnet  = module.vpc_mod.private_subnet
  vpc_id          = module.vpc_mod.vpc_id
  container_image = var.container_image
  alb_tg_lb_arn   = module.alb_mod.alb_tg_lb_arn
  ecs_sg_id       = module.security_groups_mod.ecs_sg_id
}

module "rds_mod" {
  source       = "./modules/rds"
  project_name = var.project_name
  environment  = var.environment
  rds_subnet   = module.vpc_mod.rds_subnet
  rds_sg_id    = module.security_groups_mod.rds_sg_id
  db_name      = var.db_name
  db_password  = var.db_password
  db_username  = var.db_username
}