# PostgreSQL NLB listener

The existing `envoy-gateway-nlb` has a TCP listener on port 5432 forwarding to
the `envoy-gw-postgres-30543` target group. The target group registers the
k3s instance on TCP NodePort 30543. Envoy routes that listener to the
`postgres/postgres:5432` ClusterIP service.

- Region: `ap-southeast-1`
- VPC: `vpc-017dd8b0a0b7127cb`
- Load balancer: `envoy-gateway-nlb`
- DNS: `envoy-gateway-nlb-b5b5fb7af1fe77cd.elb.ap-southeast-1.amazonaws.com`
- Target group ARN: `arn:aws:elasticloadbalancing:ap-southeast-1:051131628511:targetgroup/envoy-gw-postgres-30543/35dad9e3723ac4b2`
- Target: `i-08136987a64c2cbdc:30543`
- NLB security group: `sg-07e79ea1a2b9d6b2d`
- Node security group: `sg-0f7e6dbc456eb4a9c`
- NLB ingress currently allows TCP 5432 from `103.233.207.98/32` only.

If the client public IP changes, replace the `/32` ingress rule on the NLB
security group. Keep the node security group rule on port 30543 sourced from
the NLB security group; do not open the NodePort directly to the internet.
