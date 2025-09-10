output "vpn_gateway_id" {
  description = "ID of the VPN Gateway (VGW)"
  value       = var.create_vpn_gateway ? aws_vpn_gateway.this[0].id : var.existing_vpn_gateway_id
}

output "customer_gateway_id" {
  description = "ID of the Customer Gateway (CGW) if created or provided"
  value       = var.create_customer_gateway ? aws_customer_gateway.this[0].id : var.existing_customer_gateway_id
}

output "vpn_connection_id" {
  description = "ID of the VPN Connection"
  value       = var.create_vpn_connection ? aws_vpn_connection.this[0].id : null
}

output "vpn_connection_tunnel1_address" {
  description = "Outside IP address of the first VPN tunnel"
  value       = var.create_vpn_connection ? aws_vpn_connection.this[0].tunnel1_address : null
}

output "vpn_connection_tunnel2_address" {
  description = "Outside IP address of the second VPN tunnel"
  value       = var.create_vpn_connection ? aws_vpn_connection.this[0].tunnel2_address : null
}

output "vpn_connection_tunnel1_cgw_inside_address" {
  description = "Inside IP address of the CGW for tunnel 1"
  value       = var.create_vpn_connection ? aws_vpn_connection.this[0].tunnel1_cgw_inside_address : null
}

output "vpn_connection_tunnel2_cgw_inside_address" {
  description = "Inside IP address of the CGW for tunnel 2"
  value       = var.create_vpn_connection ? aws_vpn_connection.this[0].tunnel2_cgw_inside_address : null
}

output "vpn_connection_tunnel1_vgw_inside_address" {
  description = "Inside IP address of the VGW for tunnel 1"
  value       = var.create_vpn_connection ? aws_vpn_connection.this[0].tunnel1_vgw_inside_address : null
}

output "vpn_connection_tunnel2_vgw_inside_address" {
  description = "Inside IP address of the VGW for tunnel 2"
  value       = var.create_vpn_connection ? aws_vpn_connection.this[0].tunnel2_vgw_inside_address : null
}

output "route_propagation_enabled" {
  description = "Whether route propagation was enabled on provided route tables"
  value       = var.create_vpn_gateway && var.enable_route_propagation && length(var.route_table_ids) > 0
}

output "log_group_name" {
  description = "CloudWatch Log Group name for VPN logs (if enabled)"
  value       = var.create_vpn_connection && var.enable_vpn_logging ? aws_cloudwatch_log_group.vpn_logs[0].name : null
}

