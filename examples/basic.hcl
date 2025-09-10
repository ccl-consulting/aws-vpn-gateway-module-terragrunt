# Example: Basic VPN Gateway with Static Routes

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/your-org/aws-vpn-gateway-module-terragrunt.git?ref=v0.0.1"
}

inputs = {
  resource_prefix      = "demo-vpn"
  environment         = "dev"
  vpc_id              = "vpc-12345678"
  customer_ip_address = "203.0.113.12"

  # Enable static routes (no BGP)
  static_routes_only = true
  static_routes = [
    { destination_cidr_block = "10.0.0.0/16" }
  ]

  # Enable route propagation to route tables
  route_table_ids = [
    "rtb-11111111",
    "rtb-22222222"
  ]

  # Logging (optional)
  enable_vpn_logging = true
  log_retention_days = 30

  tags = {
    Environment = "dev"
    Project     = "vpn"
  }
}

