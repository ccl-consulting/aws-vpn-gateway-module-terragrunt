# AWS VPN Gateway Terragrunt Module

This Terragrunt module provisions and manages AWS VPN Gateway resources including VPN Gateways, Customer Gateways, and VPN Connections with comprehensive configuration options.

## Features

- **VPN Gateway**: Create or use existing Virtual Private Gateways (VGW)
- **Customer Gateway**: Create or use existing Customer Gateways (CGW) 
- **VPN Connection**: Establish IPsec VPN connections between VGW and CGW
- **Advanced Tunnel Configuration**: Comprehensive IKE and IPsec settings for both tunnels
- **Static Routing**: Support for static routes when BGP is not used
- **Route Propagation**: Automatic route propagation to specified route tables
- **Logging**: CloudWatch logging and VPC Flow Logs integration
- **High Availability**: Dual tunnel configuration for redundancy
- **Security**: Modern encryption and authentication algorithms

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   On-Premises   │     │      AWS VPC     │     │   Route Tables  │
│     Network     │◄───►│                  │     │                 │
│                 │     │  ┌─────────────┐ │     │ ┌─────────────┐ │
│ ┌─────────────┐ │     │  │VPN Gateway  │ │◄───►│ │Route Table 1│ │
│ │Customer GW  │ │     │  │   (VGW)     │ │     │ │Route Table 2│ │
│ │   (CGW)     │ │     │  └─────────────┘ │     │ │     ...     │ │
│ └─────────────┘ │     │                  │     │ └─────────────┘ │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                         │                         │
         └─────────────────────────┼─────────────────────────┘
                                   │
                    ┌───────────────┴───────────────┐
                    │         VPN Connection        │
                    │    ┌─────────┐ ┌─────────┐    │
                    │    │Tunnel 1 │ │Tunnel 2 │    │
                    │    └─────────┘ └─────────┘    │
                    └───────────────────────────────┘
```

## Usage

### Basic VPN Connection

```hcl
module "vpn_gateway" {
  source = "path/to/aws-vpn-gateway-module"

  resource_prefix     = "my-company"
  environment        = "prod"
  vpc_id             = "vpc-12345678"
  customer_ip_address = "203.0.113.12"
  
  route_table_ids = [
    "rtb-12345678",
    "rtb-87654321"
  ]

  tags = {
    Project = "NetworkInfrastructure"
    Owner   = "NetworkTeam"
  }
}
```

### Advanced Configuration with Custom Tunnel Settings

```hcl
module "vpn_gateway" {
  source = "path/to/aws-vpn-gateway-module"

  resource_prefix     = "my-company"
  environment        = "prod"
  vpc_id             = "vpc-12345678"
  customer_ip_address = "203.0.113.12"
  customer_bgp_asn   = 65001
  amazon_side_asn    = 64512

  # Advanced tunnel configuration
  tunnel1_preshared_key = "YourSecurePreSharedKey1"
  tunnel2_preshared_key = "YourSecurePreSharedKey2"
  
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers     = [14, 15, 16]
  
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase2_dh_group_numbers     = [14, 15, 16]

  # Static routing
  static_routes_only = true
  static_routes = [
    {
      destination_cidr_block = "10.0.0.0/16"
    },
    {
      destination_cidr_block = "172.16.0.0/12"
    }
  ]

  # Logging
  enable_vpn_logging = true
  enable_flow_logs   = true
  log_retention_days = 90
  
  route_table_ids = [
    "rtb-12345678",
    "rtb-87654321"
  ]

  tags = {
    Project = "NetworkInfrastructure"
    Owner   = "NetworkTeam"
  }
}
```

### Using Existing Resources

```hcl
module "vpn_gateway" {
  source = "path/to/aws-vpn-gateway-module"

  # Use existing gateways
  create_vpn_gateway      = false
  create_customer_gateway = false
  
  existing_vpn_gateway_id      = "vgw-12345678"
  existing_customer_gateway_id = "cgw-12345678"
  
  resource_prefix = "my-company"
  environment    = "prod"
}
```

## Terragrunt Configuration

### terragrunt.hcl

```hcl
terraform {
  source = "git::https://github.com/your-org/aws-vpn-gateway-module-terragrunt.git?ref=v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  resource_prefix     = "mycompany"
  environment        = "prod"
  vpc_id             = dependency.vpc.outputs.vpc_id
  customer_ip_address = "203.0.113.12"
  
  route_table_ids = [
    dependency.vpc.outputs.private_route_table_id,
    dependency.vpc.outputs.public_route_table_id
  ]
  
  # BGP configuration
  customer_bgp_asn = 65001
  amazon_side_asn  = 64512
  
  # Security settings
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  
  # Logging
  enable_vpn_logging = true
  log_retention_days = 30
  
  tags = {
    Environment = "prod"
    Project     = "network-infrastructure"
    Owner       = "platform-team"
  }
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id                   = "vpc-mock123"
    private_route_table_id   = "rtb-mock123"
    public_route_table_id    = "rtb-mock456"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2.0 |
| aws | >= 4.16 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.16 |

## Resources Created

| Resource | Description |
|----------|-------------|
| `aws_vpn_gateway` | Virtual Private Gateway for VPN connection |
| `aws_customer_gateway` | Customer Gateway representing on-premises VPN endpoint |
| `aws_vpn_connection` | IPsec VPN connection between VGW and CGW |
| `aws_vpn_connection_route` | Static routes for VPN connection (when using static routing) |
| `aws_vpn_gateway_route_propagation` | Route propagation to specified route tables |
| `aws_vpn_gateway_attachment` | VPC attachment for VGW (when not attached during creation) |
| `aws_cloudwatch_log_group` | CloudWatch log group for VPN logs (optional) |
| `aws_flow_log` | VPC Flow Logs for VPN connection (optional) |

## Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| resource_prefix | A prefix for naming resources | `string` |

### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| environment | Environment name | `string` | `""` |
| tags | Map of tags to assign to resources | `map(string)` | `{}` |
| vpc_id | VPC ID to attach VPN Gateway | `string` | `null` |
| route_table_ids | Route table IDs for propagation | `list(string)` | `[]` |
| create_vpn_gateway | Whether to create VPN Gateway | `bool` | `true` |
| create_customer_gateway | Whether to create Customer Gateway | `bool` | `true` |
| create_vpn_connection | Whether to create VPN Connection | `bool` | `true` |
| customer_ip_address | Customer gateway public IP address | `string` | `null` |
| customer_bgp_asn | Customer BGP ASN | `number` | `65000` |
| amazon_side_asn | Amazon side ASN | `number` | `64512` |
| static_routes_only | Use static routes only (disable BGP) | `bool` | `false` |
| static_routes | List of static routes | `list(object)` | `[]` |
| enable_route_propagation | Enable route propagation | `bool` | `true` |
| enable_vpn_logging | Enable VPN logging | `bool` | `false` |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `false` |
| log_retention_days | Log retention in days | `number` | `30` |

### Tunnel Configuration Inputs

Both Tunnel 1 and Tunnel 2 support the following configuration options:

| Name | Description | Type | Default |
|------|-------------|------|---------|
| tunnelX_ike_versions | IKE versions for tunnel X | `list(string)` | `["ikev1", "ikev2"]` |
| tunnelX_phase1_dh_group_numbers | Phase 1 DH group numbers | `list(number)` | `[14,15,16,17,18,19,20,21]` |
| tunnelX_phase1_encryption_algorithms | Phase 1 encryption algorithms | `list(string)` | `["AES128","AES256","AES128-GCM-16","AES256-GCM-16"]` |
| tunnelX_phase1_integrity_algorithms | Phase 1 integrity algorithms | `list(string)` | `["SHA1","SHA2-256","SHA2-384","SHA2-512"]` |
| tunnelX_phase1_lifetime_seconds | Phase 1 lifetime in seconds | `number` | `28800` |
| tunnelX_phase2_dh_group_numbers | Phase 2 DH group numbers | `list(number)` | `[2,5,14,15,16,17,18,19,20,21]` |
| tunnelX_phase2_encryption_algorithms | Phase 2 encryption algorithms | `list(string)` | `["AES128","AES256","AES128-GCM-16","AES256-GCM-16"]` |
| tunnelX_phase2_integrity_algorithms | Phase 2 integrity algorithms | `list(string)` | `["SHA1","SHA2-256","SHA2-384","SHA2-512"]` |
| tunnelX_phase2_lifetime_seconds | Phase 2 lifetime in seconds | `number` | `3600` |
| tunnelX_preshared_key | Pre-shared key for tunnel X | `string` | `null` |
| tunnelX_startup_action | Tunnel startup action | `string` | `"add"` |
| tunnelX_dpd_timeout_action | DPD timeout action | `string` | `"clear"` |
| tunnelX_dpd_timeout_seconds | DPD timeout in seconds | `number` | `30` |

## Outputs

| Name | Description |
|------|-------------|
| vpn_gateway_id | ID of the VPN Gateway |
| customer_gateway_id | ID of the Customer Gateway |
| vpn_connection_id | ID of the VPN Connection |
| vpn_connection_tunnel1_address | Public IP of tunnel 1 |
| vpn_connection_tunnel2_address | Public IP of tunnel 2 |
| vpn_connection_tunnel1_cgw_inside_address | Inside IP of CGW for tunnel 1 |
| vpn_connection_tunnel2_cgw_inside_address | Inside IP of CGW for tunnel 2 |
| vpn_connection_tunnel1_vgw_inside_address | Inside IP of VGW for tunnel 1 |
| vpn_connection_tunnel2_vgw_inside_address | Inside IP of VGW for tunnel 2 |
| route_propagation_enabled | Whether route propagation is enabled |
| log_group_name | CloudWatch Log Group name for VPN logs |

## Security Considerations

### Encryption and Authentication

- **Modern Algorithms**: Supports AES-256 encryption and SHA-256/SHA-384/SHA-512 integrity
- **Perfect Forward Secrecy**: Configurable DH groups including 14, 15, 16, 17, 18, 19, 20, 21
- **Pre-shared Keys**: Support for custom pre-shared keys (marked as sensitive)
- **IKE Versions**: Support for both IKEv1 and IKEv2

### Network Security

- **Dual Tunnels**: High availability with automatic failover
- **Dead Peer Detection**: Configurable DPD timeout and actions
- **Route Control**: Fine-grained control over route propagation
- **Network Segmentation**: Support for specific network CIDRs

### Monitoring and Logging

- **CloudWatch Integration**: Optional VPN connection logging
- **VPC Flow Logs**: Network traffic monitoring
- **Configurable Retention**: Flexible log retention policies

## Best Practices

1. **High Availability**: Always use both tunnels for redundancy
2. **Strong Encryption**: Use AES-256 with SHA-256 or higher
3. **Route Management**: Use BGP when possible; static routes for simple setups
4. **Monitoring**: Enable logging for troubleshooting and security monitoring
5. **Pre-shared Keys**: Use strong, unique pre-shared keys for each tunnel
6. **Regular Updates**: Keep tunnel configurations updated with latest security standards

## Troubleshooting

### Common Issues

1. **Tunnel Down**: Check customer gateway configuration and network connectivity
2. **Route Propagation**: Verify route table IDs and propagation settings
3. **BGP Issues**: Ensure ASN numbers are correctly configured
4. **Phase 1/2 Failures**: Review IKE and IPsec algorithm compatibility

### Debugging Commands

```bash
# Check VPN connection status
aws ec2 describe-vpn-connections --vpn-connection-ids vpn-xxxxxxxxx

# View tunnel status
aws ec2 describe-vpn-connections --vpn-connection-ids vpn-xxxxxxxxx \
  --query 'VpnConnections[0].VgwTelemetry'

# Check route propagation
aws ec2 describe-route-tables --route-table-ids rtb-xxxxxxxxx
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See LICENSE file for details.

## Support

For issues and questions:
- Create an issue in the repository
- Check the AWS VPN documentation
- Review CloudWatch logs for connection details
