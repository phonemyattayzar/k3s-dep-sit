# PostgreSQL

This chart deploys a single PostgreSQL 18 StatefulSet in the `postgres`
namespace with a persistent volume and an internal ClusterIP Service. The
separate `TCPRoute` exposes port 5432 through the shared Envoy Gateway.

## Customize database and credentials

Set `auth.username` and `auth.database` in `values.yaml`. Keep the password in
a local private values file, for example `helm/postgres/values-private.yaml`:

```yaml
auth:
  password: "replace-with-a-long-random-password"
```

The private file is ignored by Git. The chart fails to render if no password is
provided. Kubernetes Secrets are encoded at rest by default, not encrypted by
this chart; enable encryption at rest or use an external secret manager for a
production cluster.

Customize image, storage size, storage class, CPU, and memory in `values.yaml`.
PostgreSQL data is stored on the `local-path` StorageClass by default. On this
single-node k3s cluster, the volume is tied to that node; back up the database
and PVC data separately.

## Install or upgrade

```powershell
helm upgrade --install postgres .\helm\postgres --namespace postgres --create-namespace --values .\helm\postgres\values.yaml --values .\helm\postgres\values-private.yaml
```

## TCP exposure prerequisites

The Gateway listener uses TCP port 5432 and Envoy's NodePort 30543. The AWS
NLB listener and target group are configured separately in AWS; the Gateway
and TCPRoute manifests do not create AWS resources. Restrict the NLB security
group and network access to trusted clients.

The configured NLB DNS name is
`envoy-gateway-nlb-b5b5fb7af1fe77cd.elb.ap-southeast-1.amazonaws.com`. Connect
to port `5432` with database `appdb` and user `appuser`. The NLB security group
currently permits only the client IP used during setup (`103.233.207.98/32`);
update that rule if the client network changes. Envoy does not terminate TLS
for this raw TCP listener.

The cluster now runs K3s 1.34.13, Envoy Gateway 1.9.3, and Gateway API v1.6.1.
The TCPRoute `v1` is managed by the production Kustomize overlay at
`kustomize/overlay/production/namespace-resources/postgres`.
