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
  cert_arn      = module.route53_mod.cert_arn
}

module "ecs_mod" {
  source          = "./modules/ecs"
  aws_region      = var.aws_region
  project_name    = var.project_name
  environment     = var.environment
  private_subnet  = module.vpc_mod.private_subnet
  container_image = var.container_image
  alb_tg_lb_arn   = module.alb_mod.alb_tg_lb_arn
  ecs_sg_id       = module.security_groups_mod.ecs_sg_id
  rds_endpoint    = module.rds_mod.rds_endpoint
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
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

module "route53_mod" {
  source       = "./modules/route53"
  alb_dns_name = module.alb_mod.alb_dns_name
  domain_name  = var.domain_name
  alb_zone_id  = module.alb_mod.alb_zone_id
}