variable "resource_prefix" {
  description = "A prefix for naming resources"
  type        = string
  validation {
    condition     = length(var.resource_prefix) > 0 && length(var.resource_prefix) <= 50
    error_message = "Resource prefix must be between 1 and 50 characters."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.environment))
    error_message = "Environment must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC to attach the VPN Gateway to"
  type        = string
  default     = null
  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-z0-9]{8,17}$", var.vpc_id))
    error_message = "VPC ID must be a valid VPC identifier (vpc-xxxxxxxx)."
  }
}

variable "route_table_ids" {
  description = "List of route table IDs for VPN Gateway route propagation"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for rt_id in var.route_table_ids : can(regex("^rtb-[a-z0-9]{8,17}$", rt_id))
    ])
    error_message = "All route table IDs must be valid route table identifiers (rtb-xxxxxxxx)."
  }
}

variable "create_vpn_gateway" {
  description = "Whether to create a VPN Gateway"
  type        = bool
  default     = true
}

variable "vpn_gateway_name" {
  description = "Name for the VPN Gateway (defaults to resource_prefix-vgw if not specified)"
  type        = string
  default     = null
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway"
  type        = number
  default     = 64512
  validation {
    condition = (
      var.amazon_side_asn == 64512 ||
      (var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534) ||
      (var.amazon_side_asn >= 4200000000 && var.amazon_side_asn <= 4294967294)
    )
    error_message = "Amazon side ASN must be 64512, or in the range 64512-65534, or 4200000000-4294967294."
  }
}

variable "attach_to_vpc" {
  description = "Whether to attach the VPN Gateway directly to the VPC during creation"
  type        = bool
  default     = true
}

variable "existing_vpn_gateway_id" {
  description = "ID of existing VPN Gateway to use (when create_vpn_gateway is false)"
  type        = string
  default     = null
  validation {
    condition     = var.existing_vpn_gateway_id == null || can(regex("^vgw-[a-z0-9]{8,17}$", var.existing_vpn_gateway_id))
    error_message = "VPN Gateway ID must be a valid VPN Gateway identifier (vgw-xxxxxxxx)."
  }
}

variable "create_customer_gateway" {
  description = "Whether to create a Customer Gateway"
  type        = bool
  default     = true
}

variable "customer_gateway_name" {
  description = "Name for the Customer Gateway (defaults to resource_prefix-cgw if not specified)"
  type        = string
  default     = null
}

variable "customer_bgp_asn" {
  description = "The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)"
  type        = number
  default     = 65000
  validation {
    condition = (
      var.customer_bgp_asn == 65000 ||
      (var.customer_bgp_asn >= 1 && var.customer_bgp_asn <= 4294967295 &&
      !(var.customer_bgp_asn >= 64512 && var.customer_bgp_asn <= 65534))
    )
    error_message = "Customer BGP ASN must be in range 1-4294967295, excluding 64512-65534 (reserved for AWS)."
  }
}

variable "customer_ip_address" {
  description = "The IP address of the customer gateway's Internet-routable external interface"
  type        = string
  default     = null
  validation {
    condition     = var.customer_ip_address == null || can(cidrhost("${var.customer_ip_address}/32", 0))
    error_message = "Customer IP address must be a valid IPv4 address."
  }
}

variable "customer_device_name" {
  description = "A name for the customer gateway device"
  type        = string
  default     = null
}

variable "customer_certificate_arn" {
  description = "The Amazon Resource Name (ARN) for the customer gateway certificate"
  type        = string
  default     = null
  validation {
    condition     = var.customer_certificate_arn == null || can(regex("^arn:aws[a-zA-Z-]*:acm:[a-z0-9-]+:[0-9]{12}:certificate/[a-z0-9-]+$", var.customer_certificate_arn))
    error_message = "Customer certificate ARN must be a valid ACM certificate ARN."
  }
}

variable "existing_customer_gateway_id" {
  description = "ID of existing Customer Gateway to use (when create_customer_gateway is false)"
  type        = string
  default     = null
  validation {
    condition     = var.existing_customer_gateway_id == null || can(regex("^cgw-[a-z0-9]{8,17}$", var.existing_customer_gateway_id))
    error_message = "Customer Gateway ID must be a valid Customer Gateway identifier (cgw-xxxxxxxx)."
  }
}


variable "create_vpn_connection" {
  description = "Whether to create a VPN Connection"
  type        = bool
  default     = true
}

variable "vpn_connection_name" {
  description = "Name for the VPN Connection (defaults to resource_prefix-vpn if not specified)"
  type        = string
  default     = null
}

variable "static_routes_only" {
  description = "Whether the VPN connection uses static routes exclusively"
  type        = bool
  default     = false
}

variable "enable_acceleration" {
  description = "Whether the VPN connection uses AWS Global Accelerator"
  type        = bool
  default     = false
}

variable "local_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the AWS side of the VPN connection"
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(cidrhost(var.local_ipv4_network_cidr, 0))
    error_message = "Local IPv4 network CIDR must be a valid CIDR block."
  }
}

variable "remote_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the customer side of the VPN connection"
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(cidrhost(var.remote_ipv4_network_cidr, 0))
    error_message = "Remote IPv4 network CIDR must be a valid CIDR block."
  }
}

variable "local_ipv6_network_cidr" {
  description = "The IPv6 CIDR on the AWS side of the VPN connection"
  type        = string
  default     = null
}

variable "remote_ipv6_network_cidr" {
  description = "The IPv6 CIDR on the customer side of the VPN connection"
  type        = string
  default     = null
}

variable "outside_ip_address_type" {
  description = "Indicates whether the VPN tunnels process IPv4 or IPv6 traffic"
  type        = string
  default     = "PublicIpv4"
  validation {
    condition     = contains(["PublicIpv4", "PrivateIpv4"], var.outside_ip_address_type)
    error_message = "Outside IP address type must be either 'PublicIpv4' or 'PrivateIpv4'."
  }
}

variable "transport_transit_gateway_attachment_id" {
  description = "The attachment ID of the Transit Gateway attachment for VPN over Transit Gateway"
  type        = string
  default     = null
}

variable "existing_transit_gateway_id" {
  description = "ID of existing Transit Gateway to use for VPN connection"
  type        = string
  default     = null
  validation {
    condition     = var.existing_transit_gateway_id == null || can(regex("^tgw-[a-z0-9]{8,17}$", var.existing_transit_gateway_id))
    error_message = "Transit Gateway ID must be a valid Transit Gateway identifier (tgw-xxxxxxxx)."
  }
}


variable "static_routes" {
  description = "List of static routes for the VPN connection"
  type = list(object({
    destination_cidr_block = string
  }))
  default = []
  validation {
    condition = alltrue([
      for route in var.static_routes : can(cidrhost(route.destination_cidr_block, 0))
    ])
    error_message = "All destination CIDR blocks must be valid CIDR blocks."
  }
}


variable "enable_route_propagation" {
  description = "Whether to enable route propagation for the VPN Gateway"
  type        = bool
  default     = true
}


variable "tunnel1_ike_versions" {
  description = "The IKE versions that are permitted for the first VPN tunnel"
  type        = list(string)
  default     = ["ikev1", "ikev2"]
  validation {
    condition = alltrue([
      for version in var.tunnel1_ike_versions : contains(["ikev1", "ikev2"], version)
    ])
    error_message = "IKE versions must be 'ikev1' or 'ikev2'."
  }
}

variable "tunnel1_phase1_dh_group_numbers" {
  description = "List of one or more Diffie-Hellman group numbers for phase 1 IKE negotiations for the first tunnel"
  type        = list(number)
  default     = [14, 15, 16, 17, 18, 19, 20, 21]
  validation {
    condition = alltrue([
      for group in var.tunnel1_phase1_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], group)
    ])
    error_message = "Phase 1 DH group numbers must be valid DH group numbers (2, 14-24)."
  }
}

variable "tunnel1_phase1_encryption_algorithms" {
  description = "List of one or more encryption algorithms for phase 1 IKE negotiations for the first tunnel"
  type        = list(string)
  default     = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition = alltrue([
      for alg in var.tunnel1_phase1_encryption_algorithms : contains([
        "AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"
      ], alg)
    ])
    error_message = "Phase 1 encryption algorithms must be valid encryption algorithms."
  }
}

variable "tunnel1_phase1_integrity_algorithms" {
  description = "List of one or more integrity algorithms for phase 1 IKE negotiations for the first tunnel"
  type        = list(string)
  default     = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition = alltrue([
      for alg in var.tunnel1_phase1_integrity_algorithms : contains([
        "SHA1", "SHA2-256", "SHA2-384", "SHA2-512"
      ], alg)
    ])
    error_message = "Phase 1 integrity algorithms must be valid integrity algorithms."
  }
}

variable "tunnel1_phase1_lifetime_seconds" {
  description = "The lifetime for phase 1 of the IKE negotiation for the first tunnel, in seconds"
  type        = number
  default     = 28800
  validation {
    condition     = var.tunnel1_phase1_lifetime_seconds >= 900 && var.tunnel1_phase1_lifetime_seconds <= 28800
    error_message = "Phase 1 lifetime must be between 900 and 28800 seconds."
  }
}

variable "tunnel1_phase2_dh_group_numbers" {
  description = "List of one or more Diffie-Hellman group numbers for phase 2 IKE negotiations for the first tunnel"
  type        = list(number)
  default     = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21]
  validation {
    condition = alltrue([
      for group in var.tunnel1_phase2_dh_group_numbers : contains([2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], group)
    ])
    error_message = "Phase 2 DH group numbers must be valid DH group numbers (2, 5, 14-24)."
  }
}

variable "tunnel1_phase2_encryption_algorithms" {
  description = "List of one or more encryption algorithms for phase 2 IKE negotiations for the first tunnel"
  type        = list(string)
  default     = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition = alltrue([
      for alg in var.tunnel1_phase2_encryption_algorithms : contains([
        "AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"
      ], alg)
    ])
    error_message = "Phase 2 encryption algorithms must be valid encryption algorithms."
  }
}

variable "tunnel1_phase2_integrity_algorithms" {
  description = "List of one or more integrity algorithms for phase 2 IKE negotiations for the first tunnel"
  type        = list(string)
  default     = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition = alltrue([
      for alg in var.tunnel1_phase2_integrity_algorithms : contains([
        "SHA1", "SHA2-256", "SHA2-384", "SHA2-512"
      ], alg)
    ])
    error_message = "Phase 2 integrity algorithms must be valid integrity algorithms."
  }
}

variable "tunnel1_phase2_lifetime_seconds" {
  description = "The lifetime for phase 2 of the IKE negotiation for the first tunnel, in seconds"
  type        = number
  default     = 3600
  validation {
    condition     = var.tunnel1_phase2_lifetime_seconds >= 900 && var.tunnel1_phase2_lifetime_seconds <= 3600
    error_message = "Phase 2 lifetime must be between 900 and 3600 seconds."
  }
}

variable "tunnel1_preshared_key" {
  description = "The preshared key of the first VPN tunnel"
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition     = var.tunnel1_preshared_key == null || can(length(var.tunnel1_preshared_key) >= 8 && length(var.tunnel1_preshared_key) <= 64)
    error_message = "Preshared key must be between 8 and 64 characters long."
  }
}

variable "tunnel1_rekey_fuzz_percentage" {
  description = "Percentage of tunnel1_rekey_margin_time_seconds to use for randomizing rekey time for the first tunnel"
  type        = number
  default     = 100
  validation {
    condition     = var.tunnel1_rekey_fuzz_percentage >= 0 && var.tunnel1_rekey_fuzz_percentage <= 100
    error_message = "Rekey fuzz percentage must be between 0 and 100."
  }
}

variable "tunnel1_rekey_margin_time_seconds" {
  description = "Margin time before the phase 2 lifetime expires to initiate new phase 2 negotiation for the first tunnel"
  type        = number
  default     = 540
  validation {
    condition     = var.tunnel1_rekey_margin_time_seconds >= 60 && var.tunnel1_rekey_margin_time_seconds <= 1800
    error_message = "Rekey margin time must be between 60 and 1800 seconds."
  }
}

variable "tunnel1_replay_window_size" {
  description = "The number of packets in an IKE replay window for the first tunnel"
  type        = number
  default     = 1024
  validation {
    condition     = contains([64, 128, 256, 512, 1024, 2048], var.tunnel1_replay_window_size)
    error_message = "Replay window size must be one of: 64, 128, 256, 512, 1024, 2048."
  }
}

variable "tunnel1_startup_action" {
  description = "The action to take when the establishing the tunnel for the first VPN connection"
  type        = string
  default     = "add"
  validation {
    condition     = contains(["add", "start"], var.tunnel1_startup_action)
    error_message = "Startup action must be either 'add' or 'start'."
  }
}

variable "tunnel1_dpd_timeout_action" {
  description = "The action to take after DPD timeout occurs for the first tunnel"
  type        = string
  default     = "clear"
  validation {
    condition     = contains(["clear", "none", "restart"], var.tunnel1_dpd_timeout_action)
    error_message = "DPD timeout action must be 'clear', 'none', or 'restart'."
  }
}

variable "tunnel1_dpd_timeout_seconds" {
  description = "The number of seconds after which a DPD timeout occurs for the first tunnel"
  type        = number
  default     = 30
  validation {
    condition     = var.tunnel1_dpd_timeout_seconds >= 30 && var.tunnel1_dpd_timeout_seconds <= 3600
    error_message = "DPD timeout must be between 30 and 3600 seconds."
  }
}

variable "tunnel1_enable_tunnel_lifecycle_control" {
  description = "Whether to enable tunnel lifecycle control for the first tunnel"
  type        = bool
  default     = false
}


variable "tunnel2_ike_versions" {
  description = "The IKE versions that are permitted for the second VPN tunnel"
  type        = list(string)
  default     = ["ikev1", "ikev2"]
  validation {
    condition = alltrue([
      for version in var.tunnel2_ike_versions : contains(["ikev1", "ikev2"], version)
    ])
    error_message = "IKE versions must be 'ikev1' or 'ikev2'."
  }
}

variable "tunnel2_phase1_dh_group_numbers" {
  description = "List of one or more Diffie-Hellman group numbers for phase 1 IKE negotiations for the second tunnel"
  type        = list(number)
  default     = [14, 15, 16, 17, 18, 19, 20, 21]
  validation {
    condition = alltrue([
      for group in var.tunnel2_phase1_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], group)
    ])
    error_message = "Phase 1 DH group numbers must be valid DH group numbers (2, 14-24)."
  }
}

variable "tunnel2_phase1_encryption_algorithms" {
  description = "List of one or more encryption algorithms for phase 1 IKE negotiations for the second tunnel"
  type        = list(string)
  default     = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition = alltrue([
      for alg in var.tunnel2_phase1_encryption_algorithms : contains([
        "AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"
      ], alg)
    ])
    error_message = "Phase 1 encryption algorithms must be valid encryption algorithms."
  }
}

variable "tunnel2_phase1_integrity_algorithms" {
  description = "List of one or more integrity algorithms for phase 1 IKE negotiations for the second tunnel"
  type        = list(string)
  default     = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition = alltrue([
      for alg in var.tunnel2_phase1_integrity_algorithms : contains([
        "SHA1", "SHA2-256", "SHA2-384", "SHA2-512"
      ], alg)
    ])
    error_message = "Phase 1 integrity algorithms must be valid integrity algorithms."
  }
}

variable "tunnel2_phase1_lifetime_seconds" {
  description = "The lifetime for phase 1 of the IKE negotiation for the second tunnel, in seconds"
  type        = number
  default     = 28800
  validation {
    condition     = var.tunnel2_phase1_lifetime_seconds >= 900 && var.tunnel2_phase1_lifetime_seconds <= 28800
    error_message = "Phase 1 lifetime must be between 900 and 28800 seconds."
  }
}

variable "tunnel2_phase2_dh_group_numbers" {
  description = "List of one or more Diffie-Hellman group numbers for phase 2 IKE negotiations for the second tunnel"
  type        = list(number)
  default     = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21]
  validation {
    condition = alltrue([
      for group in var.tunnel2_phase2_dh_group_numbers : contains([2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], group)
    ])
    error_message = "Phase 2 DH group numbers must be valid DH group numbers (2, 5, 14-24)."
  }
}

variable "tunnel2_phase2_encryption_algorithms" {
  description = "List of one or more encryption algorithms for phase 2 IKE negotiations for the second tunnel"
  type        = list(string)
  default     = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition = alltrue([
      for alg in var.tunnel2_phase2_encryption_algorithms : contains([
        "AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"
      ], alg)
    ])
    error_message = "Phase 2 encryption algorithms must be valid encryption algorithms."
  }
}

variable "tunnel2_phase2_integrity_algorithms" {
  description = "List of one or more integrity algorithms for phase 2 IKE negotiations for the second tunnel"
  type        = list(string)
  default     = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition = alltrue([
      for alg in var.tunnel2_phase2_integrity_algorithms : contains([
        "SHA1", "SHA2-256", "SHA2-384", "SHA2-512"
      ], alg)
    ])
    error_message = "Phase 2 integrity algorithms must be valid integrity algorithms."
  }
}

variable "tunnel2_phase2_lifetime_seconds" {
  description = "The lifetime for phase 2 of the IKE negotiation for the second tunnel, in seconds"
  type        = number
  default     = 3600
  validation {
    condition     = var.tunnel2_phase2_lifetime_seconds >= 900 && var.tunnel2_phase2_lifetime_seconds <= 3600
    error_message = "Phase 2 lifetime must be between 900 and 3600 seconds."
  }
}

variable "tunnel2_preshared_key" {
  description = "The preshared key of the second VPN tunnel"
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition     = var.tunnel2_preshared_key == null || can(length(var.tunnel2_preshared_key) >= 8 && length(var.tunnel2_preshared_key) <= 64)
    error_message = "Preshared key must be between 8 and 64 characters long."
  }
}

variable "tunnel2_rekey_fuzz_percentage" {
  description = "Percentage of tunnel2_rekey_margin_time_seconds to use for randomizing rekey time for the second tunnel"
  type        = number
  default     = 100
  validation {
    condition     = var.tunnel2_rekey_fuzz_percentage >= 0 && var.tunnel2_rekey_fuzz_percentage <= 100
    error_message = "Rekey fuzz percentage must be between 0 and 100."
  }
}

variable "tunnel2_rekey_margin_time_seconds" {
  description = "Margin time before the phase 2 lifetime expires to initiate new phase 2 negotiation for the second tunnel"
  type        = number
  default     = 540
  validation {
    condition     = var.tunnel2_rekey_margin_time_seconds >= 60 && var.tunnel2_rekey_margin_time_seconds <= 1800
    error_message = "Rekey margin time must be between 60 and 1800 seconds."
  }
}

variable "tunnel2_replay_window_size" {
  description = "The number of packets in an IKE replay window for the second tunnel"
  type        = number
  default     = 1024
  validation {
    condition     = contains([64, 128, 256, 512, 1024, 2048], var.tunnel2_replay_window_size)
    error_message = "Replay window size must be one of: 64, 128, 256, 512, 1024, 2048."
  }
}

variable "tunnel2_startup_action" {
  description = "The action to take when the establishing the tunnel for the second VPN connection"
  type        = string
  default     = "add"
  validation {
    condition     = contains(["add", "start"], var.tunnel2_startup_action)
    error_message = "Startup action must be either 'add' or 'start'."
  }
}

variable "tunnel2_dpd_timeout_action" {
  description = "The action to take after DPD timeout occurs for the second tunnel"
  type        = string
  default     = "clear"
  validation {
    condition     = contains(["clear", "none", "restart"], var.tunnel2_dpd_timeout_action)
    error_message = "DPD timeout action must be 'clear', 'none', or 'restart'."
  }
}

variable "tunnel2_dpd_timeout_seconds" {
  description = "The number of seconds after which a DPD timeout occurs for the second tunnel"
  type        = number
  default     = 30
  validation {
    condition     = var.tunnel2_dpd_timeout_seconds >= 30 && var.tunnel2_dpd_timeout_seconds <= 3600
    error_message = "DPD timeout must be between 30 and 3600 seconds."
  }
}

variable "tunnel2_enable_tunnel_lifecycle_control" {
  description = "Whether to enable tunnel lifecycle control for the second tunnel"
  type        = bool
  default     = false
}


variable "enable_vpn_logging" {
  description = "Whether to enable VPN connection logging"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs for the VPN connection"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain VPN logs in CloudWatch"
  type        = number
  default     = 365
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be one of the allowed CloudWatch values."
  }
}

variable "flow_log_iam_role_arn" {
  description = "The ARN for the IAM role that permits the service to publish flow logs to a CloudWatch Logs log group"
  type        = string
  default     = null
  validation {
    condition     = var.flow_log_iam_role_arn == null || can(regex("^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:role/.+", var.flow_log_iam_role_arn))
    error_message = "Flow log IAM role ARN must be a valid IAM role ARN."
  }
}

variable "log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data"
  type        = string
  default     = null
  validation {
    condition     = var.log_group_kms_key_id == null || can(regex("^arn:aws[a-zA-Z-]*:kms:[a-z0-9-]+:[0-9]{12}:key/[a-z0-9-]+", var.log_group_kms_key_id)) || can(regex("^[a-z0-9-]+$", var.log_group_kms_key_id))
    error_message = "KMS Key ID must be a valid KMS key ARN, key ID, or alias."
  }
}
