locals {
  shield_tags = merge(var.base_tags, {
    Service      = "shield"
    Layer        = "security"
    Type         = "ddos-protection"
    SecurityTier = "advanced"
  })
}