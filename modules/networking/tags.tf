locals {
    alb_tags = merge(var.base_tags, {
        Service = "alb"
        Layer   = "network"
    })
    cloudfront_tags = merge(var.base_tags, {
        Service = "cloudfront"
        Layer   = "edge"
    })
}

