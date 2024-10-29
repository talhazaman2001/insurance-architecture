# RDS Aurora Cluster
resource "aws_rds_cluster" "insurance_cluster" {
    cluster_identifier = "insurance-cluster"
    engine = "aurora-postgresql"
    engine_version = "15.3"
    database_name = "insurancedatabase"
    master_username = "username"
    master_password = "password"
    port = 5432

    vpc_security_group_ids = [aws_security_group.aurora_sg.id]
    db_subnet_group_name = aws_db_subnet_group.aurora_subnet.name

    backup_retention_period = 7
    preferred_backup_window = "03:00-04:00"
    skip_final_snapshot = true
    storage_encrypted = true 

    enabled_cloudwatch_logs_exports = [ "postgresql" ]

    tags = local.aurora_tags
}

# Aurora Instance
resource "aws_rds_cluster_instance" "insurance_instance" {
    count = 2
    identifier = "insurance-cluster-${count.index}"
    cluster_identifier = aws_rds_cluster.insurance_cluster.id 
    instance_class = "db.r6g.large"
    engine = aws_rds_cluster.insurance_cluster.engine 
    engine_version = aws_rds_cluster.insurance_cluster.engine_version 

    tags = local.aurora_tags
}

# Aurora Security Group
resource "aws_security_group" "aurora_sg" {
    name = "aurora-sg"
    description = "Security Group for Aurora Cluster"
    vpc_id = var.vpc_id 

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [var.fargate_tasks_sg_id]
    }

    tags = local.aurora_sg_tags
}

# Aurora Subnet Group
resource "aws_db_subnet_group" "aurora_subnet" {
    name = "insurance-aurora-subnet-group"
    subnet_ids = var.private_subnets

    tags = local.aurora_subnet_tags
}

# Parameter Group for PostgreSQL Optimisations
resource "aws_rds_cluster_parameter_group" "insurance" {
    family = "aurora-postgresql15"
    name = "insurance-parameters-talha"

    parameter {
        name = "shared_preload_libraries"
        value = "pg_stat_statements,pg_hint_plan" # Track query performance and manual query optimisation
        apply_method = "pending-reboot"
    }

    parameter {
      name = "log_min_duration_statement"
      value = "1000" # Log queries taking more than one second
      apply_method = "immediate"
    }

    lifecycle {
      create_before_destroy = true
    }

    tags = local.aurora_subnet_tags
}


