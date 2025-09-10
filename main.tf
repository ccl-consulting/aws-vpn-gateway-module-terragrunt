terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_route_table" "propagation" {
  count          = length(var.route_table_ids)
  route_table_id = var.route_table_ids[count.index]
}

locals {
  vgw_name              = var.vpn_gateway_name != null ? var.vpn_gateway_name : "${var.resource_prefix}-vgw"
  cgw_name              = var.customer_gateway_name != null ? var.customer_gateway_name : "${var.resource_prefix}-cgw"
  vpn_connection_name   = var.vpn_connection_name != null ? var.vpn_connection_name : "${var.resource_prefix}-vpn"
  create_vpc_attachment = var.create_vpn_gateway && var.vpc_id != null
  common_tags = merge(
    {
      Name        = var.resource_prefix
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

resource "aws_vpn_gateway" "this" {
  count           = var.create_vpn_gateway ? 1 : 0
  vpc_id          = var.attach_to_vpc ? var.vpc_id : null
  amazon_side_asn = var.amazon_side_asn

  tags = merge(
    local.common_tags,
    {
      Name = local.vgw_name
    }
  )
}

resource "aws_vpn_gateway_attachment" "this" {
  count          = var.create_vpn_gateway && !var.attach_to_vpc && var.vpc_id != null ? 1 : 0
  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.this[0].id
}

resource "aws_customer_gateway" "this" {
  count           = var.create_customer_gateway ? 1 : 0
  bgp_asn         = var.customer_bgp_asn
  ip_address      = var.customer_ip_address
  type            = "ipsec.1"
  device_name     = var.customer_device_name
  certificate_arn = var.customer_certificate_arn

  tags = merge(
    local.common_tags,
    {
      Name = local.cgw_name
    }
  )
}

resource "aws_vpn_connection" "this" {
  count                                   = var.create_vpn_connection ? 1 : 0
  type                                    = "ipsec.1"
  customer_gateway_id                     = var.create_customer_gateway ? aws_customer_gateway.this[0].id : var.existing_customer_gateway_id
  vpn_gateway_id                          = var.existing_transit_gateway_id == null ? (var.create_vpn_gateway ? aws_vpn_gateway.this[0].id : var.existing_vpn_gateway_id) : null
  transit_gateway_id                      = var.existing_transit_gateway_id
  static_routes_only                      = var.static_routes_only
  enable_acceleration                     = var.existing_transit_gateway_id != null ? var.enable_acceleration : false
  local_ipv4_network_cidr                 = var.local_ipv4_network_cidr
  remote_ipv4_network_cidr                = var.remote_ipv4_network_cidr
  local_ipv6_network_cidr                 = var.local_ipv6_network_cidr
  remote_ipv6_network_cidr                = var.remote_ipv6_network_cidr
  outside_ip_address_type                 = var.outside_ip_address_type
  transport_transit_gateway_attachment_id = var.transport_transit_gateway_attachment_id

  tunnel1_ike_versions = var.tunnel1_ike_versions

  tunnel1_phase1_dh_group_numbers         = var.tunnel1_phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms    = var.tunnel1_phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms     = var.tunnel1_phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds         = var.tunnel1_phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers         = var.tunnel1_phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms    = var.tunnel1_phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms     = var.tunnel1_phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds         = var.tunnel1_phase2_lifetime_seconds
  tunnel1_preshared_key                   = var.tunnel1_preshared_key
  tunnel1_rekey_fuzz_percentage           = var.tunnel1_rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds       = var.tunnel1_rekey_margin_time_seconds
  tunnel1_replay_window_size              = var.tunnel1_replay_window_size
  tunnel1_startup_action                  = var.tunnel1_startup_action
  tunnel1_dpd_timeout_action              = var.tunnel1_dpd_timeout_action
  tunnel1_dpd_timeout_seconds             = var.tunnel1_dpd_timeout_seconds
  tunnel1_enable_tunnel_lifecycle_control = var.tunnel1_enable_tunnel_lifecycle_control

  tunnel2_ike_versions = var.tunnel2_ike_versions

  tunnel2_phase1_dh_group_numbers         = var.tunnel2_phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms    = var.tunnel2_phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms     = var.tunnel2_phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds         = var.tunnel2_phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers         = var.tunnel2_phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms    = var.tunnel2_phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms     = var.tunnel2_phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds         = var.tunnel2_phase2_lifetime_seconds
  tunnel2_preshared_key                   = var.tunnel2_preshared_key
  tunnel2_rekey_fuzz_percentage           = var.tunnel2_rekey_fuzz_percentage
  tunnel2_rekey_margin_time_seconds       = var.tunnel2_rekey_margin_time_seconds
  tunnel2_replay_window_size              = var.tunnel2_replay_window_size
  tunnel2_startup_action                  = var.tunnel2_startup_action
  tunnel2_dpd_timeout_action              = var.tunnel2_dpd_timeout_action
  tunnel2_dpd_timeout_seconds             = var.tunnel2_dpd_timeout_seconds
  tunnel2_enable_tunnel_lifecycle_control = var.tunnel2_enable_tunnel_lifecycle_control

  tags = merge(
    local.common_tags,
    {
      Name = local.vpn_connection_name
    }
  )

  depends_on = [
    aws_vpn_gateway.this,
    aws_customer_gateway.this
  ]
}

resource "aws_vpn_connection_route" "this" {
  count                  = var.create_vpn_connection && var.static_routes_only && length(var.static_routes) > 0 ? length(var.static_routes) : 0
  destination_cidr_block = var.static_routes[count.index].destination_cidr_block
  vpn_connection_id      = aws_vpn_connection.this[0].id
}

resource "aws_vpn_gateway_route_propagation" "this" {
  count          = var.create_vpn_gateway && var.enable_route_propagation && length(var.route_table_ids) > 0 ? length(var.route_table_ids) : 0
  vpn_gateway_id = aws_vpn_gateway.this[0].id
  route_table_id = var.route_table_ids[count.index]
}

resource "aws_cloudwatch_log_group" "vpn_logs" {
  count             = var.create_vpn_connection && var.enable_vpn_logging ? 1 : 0
  name              = "/aws/vpn/${local.vpn_connection_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.vpn_connection_name}-logs"
    }
  )
}

resource "aws_flow_log" "vpn_flow_logs" {
  count           = var.create_vpn_connection && var.enable_flow_logs ? 1 : 0
  iam_role_arn    = var.flow_log_iam_role_arn
  log_destination = aws_cloudwatch_log_group.vpn_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.vpn_connection_name}-flow-logs"
    }
  )
}
