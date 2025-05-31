resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id
}

resource "aws_customer_gateway" "this" {
  bgp_asn    = var.bgp_asn
  ip_address = var.customer_ip
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "this" {
  customer_gateway_id = aws_customer_gateway.this.id
  vpn_gateway_id      = aws_vpn_gateway.this.id
  type                = "ipsec.1"
}
