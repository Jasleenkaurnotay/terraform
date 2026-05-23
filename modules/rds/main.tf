#Using RDS data source to determine few values like ca_cert_identifier, engine version etc

data "aws_rds_certificate" "latest" {
    latest_valid_till = true
}

data "aws_rds_engine_version" "latest_postgres" {
    engine = "postgres"
}

# Create DB Subnet group with private RDS subnets 
resource "aws_db_subnet_group" "rds_db_subnet_group" {
    name = "${var.project_name}-rds-db-subnet-group"
    subnet_ids = var.rds_subnet

    tags = {
        Name = "${var.project_name}-rds-db-subnet-group"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}


resource "aws_db_instance" "rds_db" {
  allocated_storage    = 20
  identifier = "${var.project_name}-rds-db"
  db_name              = "${var.db_name}"
  engine               = "postgres"
  engine_version       = data.aws_rds_engine_version.latest_postgres.version
  instance_class       = "db.t3.micro"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  apply_immediately = true
  ca_cert_identifier = data.aws_rds_certificate.latest.id
  db_subnet_group_name = aws_db_subnet_group.rds_db_subnet_group.name
  publicly_accessible = false
  storage_type = "gp2"
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-rds-db"
    Environment = "${var.environment}"
    ManagedBy = "Terraform"
  }
}