# Compute
variable "ecs_cluster_name" {
	type = string
	description = "ECS Cluster Name"
}

variable "service_names" {
	type = map(string)
	default = {
		fraud_detection = "fraud-detection-engine"
		risk_assessment = "risk-assessment-service"
		claims_processing = "claims-processing-service"
	}
}

# Data-Storage
variable "codepipeline_artifacts_arn" {
    type = string
    description = "CodePipeline Artifacts S3 Bucket ARN"
}

variable "codepipeline_artifacts_bucket" {
    type = string
    description = "CodePipeline Artifacts S3 Bucket"
}

# Monitoring
variable "codebuild_log_group_arn" {
    type = string
    description = "CodeBuild CloudWatch Log Group ARN"
}

# Networking

variable "fraud_detection_engine_blue_tg_arn" {
	type = string
}

variable "fraud_detection_engine_green_tg_arn" {
	type = string
}

variable "risk_assessment_service_blue_tg_arn" {
	type = string
}

variable "risk_assessment_service_green_tg_arn" {
	type = string
}

variable "claims_processing_service_blue_tg_arn" {
	type = string
}

variable "claims_processing_service_green_tg_arn" {
	type = string
}

variable "fargate_alb_listener_arn" {
	type = string
}