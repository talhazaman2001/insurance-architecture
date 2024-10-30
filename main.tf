# Analytics Modules
module "analytics" {
  source = "./modules/analytics"

  base_tags = var.base_tags
  athena_results_bucket = module.data-storage.athena_results_bucket
  insurance_bucket_id = module.data-storage.insurance_bucket_id
  glue_role_arn = module.security.glue_role_arn
  sagemaker_role_arn = module.security.sagemaker_role_arn
  sagemaker_model_artifacts_id = module.data-storage.sagemaker_model_artifacts_id
}

# Compute Modules
module "compute" {
  source = "./modules/compute"
  
  base_tags = var.base_tags
  private_subnets = module.networking.private_subnet_ids
  kinesis_stream_arn = module.monitoring.kinesis_stream_arn
  alb_sg_id = module.networking.alb_sg_id
  api_gateway_role_arn = module.security.api_gateway_role_arn
  api_gateway_attach = module.security.api_gateway_attach
  insurance_bucket_arn = module.data-storage.insurance_bucket_arn
  dynamodb_table_arn = module.data-storage.dynamodb_table_arn
  fraud_detection_engine_log_group_name = "/aws/fargate/fraud-detection-engine"
  risk_assessment_service_log_group_name = "/aws/fargate/risk-assessment-service"
  claims_processing_service_log_group_name = "/aws/fargate/claims-processing-service"
  vpc_id = module.networking.vpc_id
  aurora_endpoint = module.data-storage.aurora_endpoint
  dynamodb_table_name = module.data-storage.dynamodb_table_name
  insurance_bucket_id = module.data-storage.insurance_bucket_id
  xray_log_group_arn = module.monitoring.xray_log_group_arn
  repository_urls = module.data-storage.repository_urls
  fargate_alb_listener_arn = module.networking.fargate_alb_listener_arn
  fraud_detection_engine_blue_tg_arn = module.networking.fraud_detection_engine_blue_tg_arn
  risk_assessment_service_blue_tg_arn = module.networking.risk_assessment_service_blue_tg_arn
  claims_processing_service_blue_tg_arn = module.networking.claims_processing_service_blue_tg_arn
  fargate_execution_role_arn = module.security.fargate_execution_role_arn
  fargate_task_role_arn = module.security.fargate_task_role_arn
}

# Data-storage modules
module "data-storage" {
  source = "./modules/data-storage"
  
  base_tags = var.base_tags
  private_subnets = module.networking.private_subnet_ids
  vpc_id = module.networking.vpc_id
  endpoint_sg = module.networking.vpc_interface_endpoint_sg_id
  private_rt_id = [module.networking.private_rt_id]
  fargate_tasks_sg_id = module.compute.fargate_tasks_sg_id
}


# Monitoring modules
module "monitoring" {
  source = "./modules/monitoring"
  
  base_tags = var.base_tags
  api_gateway_id = module.compute.api_gateway_id
  fargate_alb_arn = module.networking.fargate_alb_arn
  fraud_detection_engine_blue_tg_arn = module.networking.fraud_detection_engine_blue_tg_arn
  risk_assessment_service_blue_tg_arn = module.networking.risk_assessment_service_blue_tg_arn
  claims_processing_service_blue_tg_arn = module.networking.claims_processing_service_blue_tg_arn
  ecs_cluster_name = module.compute.ecs_cluster_name
  aurora_cluster_arn = module.data-storage.aurora_cluster_arn
  sagemaker_endpoint_name = module.analytics.sagemaker_endpoint_name
  waf_web_acl_name = module.security.waf_web_acl_name
  classification_job_id = module.security.classification_job_id
}

# Networking modules
module "networking" {
  source = "./modules/networking"

  environment = var.environment
  private_subnets = module.networking.private_subnet_ids
  public_subnets = module.networking.public_subnet_ids
  base_tags = var.base_tags
  api_gateway_endpoint = var.api_gateway_endpoint
  waf_web_acl_id = var.waf_web_acl_id
  waf_web_acl_arn = var.waf_web_acl_arn
  waf_log_group_arn = var.waf_log_group_arn
}

# Security Modules
module "security" {
  source = "./modules/security"
  
  base_tags = var.base_tags
  insurance_bucket_arn = module.data-storage.insurance_bucket_arn
  athena_results_arn = module.data-storage.athena_results_arn
  sagemaker_log_group_arn = module.monitoring.sagemaker_log_group_arn
  fargate_alb_arn = module.networking.fargate_alb_arn
  api_gateway_log_group_arn = var.api_gateway_log_group_arn
  alb_log_group_arn = module.monitoring.alb_log_group_arn
  dynamodb_table_arn = module.data-storage.dynamodb_table_arn
  repositories = module.data-storage.repository_arns
  fraud_detection_engine_log_group_arn = module.monitoring.fraud_detection_engine_log_group_arn
  risk_assessment_service_log_group_arn = module.monitoring.risk_assessment_service_log_group_arn
  claims_processing_service_log_group_arn = module.monitoring.claims_processing_service_log_group_arn
  macie_log_group_arn = module.monitoring.macie_log_group_arn
  sagemaker_model_artifacts_arn = module.data-storage.sagemaker_model_artifacts_arn
  aurora_cluster_arn = module.data-storage.aurora_cluster_arn
  sns_topic_arn = module.monitoring.sns_topic_arn
  kinesis_stream_arn = module.monitoring.kinesis_stream_arn
  sagemaker_endpoint_arn = module.analytics.sagemaker_endpoint_arn
  sagemaker_model_arn = module.analytics.sagemaker_model_arn
  cdn_arn = var.cdn_arn
  route53_zone_arn = module.networking.route53_zone_arn
  waf_log_group_arn = module.monitoring.waf_log_group_arn
  sagemaker_xgboost_repository_arn = module.data-storage.sagemaker_xgboost_repository_arn
  repository_arns = module.data-storage.repository_arns
}

# CI/CD Modules
module "CICD" {
  source = "./cicd"

  codepipeline_artifacts_arn = module.data-storage.codepipeline_artifacts_arn
  codebuild_log_group_arn = module.monitoring.codebuild_log_group_arn
  codepipeline_artifacts_bucket = module.data-storage.codepipeline_artifacts_bucket
  ecs_cluster_name = module.compute.ecs_cluster_name
  service_names = module.compute.service_names
  fargate_alb_listener_arn = module.networking.fargate_alb_listener_arn
  fraud_detection_engine_blue_tg_arn = module.networking.fraud_detection_engine_blue_tg_arn
  fraud_detection_engine_green_tg_arn = module.networking.fraud_detection_engine_green_tg_arn
  claims_processing_service_blue_tg_arn = module.networking.claims_processing_service_blue_tg_arn
  claims_processing_service_green_tg_arn = module.networking.claims_processing_service_green_tg_arn
  risk_assessment_service_blue_tg_arn = module.networking.risk_assessment_service_blue_tg_arn
  risk_assessment_service_green_tg_arn = module.networking.risk_assessment_service_green_tg_arn
}



