# Tags for the Global Insurance Architecture
locals {
 base_tags = {
   Environment = var.environment
   Project     = "insurance-architcture"
   Owner       = "me"
   ManagedBy   = "terraform"
   CostCenter  = "insurance-tech"
 }
}