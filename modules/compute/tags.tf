locals {
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

    fargate_tags = merge(var.base_tags, {
        Service = "fargate"
        Layer   = "compute"
    })

    api_gateway_tags = merge(var.base_tags, {
        Service = "api-gateway"
        Layer   = "edge"
    })
}

