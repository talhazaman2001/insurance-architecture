locals { 
    ecr_tags = merge(var.base_tags, {
    Service     = "ecr"
    Layer       = "container-registry"
    Type        = "container-images"
    Compliance  = "required"  
    })

    container_tags = {
        fraud_detection_engine = merge(var.base_tags, {
            Service     = "fraud-detection-engine"
            Layer       = "microservice"
            AppType     = "fraud-detection"
        })
        risk_assessment_service = merge(var.base_tags, {
            Service     = "risk-assessment-service"
            Layer       = "microservice"
            AppType     = "risk-assessment"
        })
        claims_processing_service = merge(var.base_tags, {
            Service     = "claims-processing-service"
            Layer       = "microservice"
            AppType     = "claims-processing"
        })
    }

    s3_insurance_tags = merge(var.base_tags, {
        Service = "S3"
        Name = "Insurance Raw Data Bucket"
    })

    s3_sagemaker_tags = merge(var.base_tags, {
        Service = "S3"
        Name = "SageMaker Training Data and Model Artifacts Bucket"
    })

    s3_pipeline_tags = merge(var.base_tags, {
        Service = "S3"
        Name = "CodePipeline Artifacts Bucket"
    })

    aurora_tags = merge(var.base_tags, {
        Service = "aurora"
        Layer = "database"
        Name = "Insurance Database"
    })

    aurora_sg_tags = merge(var.base_tags, {
        Name = "aurora-sg"
        Service = "aurora"
    })

    aurora_subnet_tags = merge(var.base_tags, {
        Service = "aurora"
    })
}