# WAF
output "waf_web_acl_id" {
    value = aws_wafv2_web_acl.global_insurance.id
}

output "waf_web_acl_arn" {
    value = aws_wafv2_web_acl.global_insurance.arn
}

output "waf_web_acl_name" {
    value = aws_wafv2_web_acl.global_insurance.name
}

# IAM
output "api_gateway_role_arn" {
    value = aws_iam_role.api_gateway_role.arn
}

output "api_gateway_attach" {
  value = aws_iam_role_policy_attachment.api_gateway_attach.id
}

output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}

output "sagemaker_role_arn" {
  value = aws_iam_role.sagemaker_role.arn
}

output "fargate_execution_role_arn" {
  value = aws_iam_role.fargate_execution_role.arn
}

output "fargate_task_role_arn" {
  value = aws_iam_role.fargate_task_role.arn
}

# MACIE 
output "classification_job_id" {
    value = aws_macie2_classification_job.s3_sensitive_data.id
}