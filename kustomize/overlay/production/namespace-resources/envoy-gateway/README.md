# Envoy Gateway and private certificate chain

This directory contains the shared Gateway API resources. The Helm chart
configuration remains in `helm/envoy-gateway/values.yaml`, and the cert-manager
CA chain is maintained separately in `kustomize/overlay/production/namespace-resources/cert-manager/`.

## Before applying

1. Install cert-manager and Envoy Gateway first. The cert-manager CRDs must be
   available before applying these manifests.
2. The HTTPS certificate covers `*.dat.com`. This covers one-level subdomains
   such as `app.dat.com`, but not the apex `dat.com` or deeper names such as
   `api.dev.dat.com`.
3. Apply the CA chain, wait for the leaf certificate, then apply the shared
   Gateway resources:

   ```powershell
   kubectl apply -k .\kustomize\overlay\production\namespace-resources\cert-manager
   kubectl wait --for=condition=Ready certificate/envoy-gateway-tls -n envoy-gateway-system --timeout=10m
   kubectl apply -k .\kustomize\overlay\production\namespace-resources\envoy-gateway
   ```

cert-manager will reconcile the chain asynchronously. The HTTPS listener is
usable once `Certificate/envoy-gateway-tls` is Ready and its Secret exists.
Check the resources with:

```powershell
kubectl get clusterissuer,certificate -A
kubectl get gatewayclass,gateway -A
kubectl get svc -n envoy-gateway-system
```

Both Gateway listeners accept routes from every namespace. This is convenient
for a shared Gateway; use Kubernetes RBAC to control who can create or modify
HTTPRoutes and other route resources.

The NLB must target the Envoy data-plane Service on NodePorts 30080 and 30443.
PostgreSQL also needs an NLB listener on TCP 5432 forwarding to NodePort 30543.
The AWS NLB is managed separately; these manifests do not provision its
listener or target group.

## PKI note

This in-cluster root CA is a simple private-PKI bootstrap example. Its signing
key is stored in a Kubernetes Secret. For production, prefer an offline or
externally managed root CA, establish secure backup and rotation procedures,
and distribute the root certificate to every client that must trust the HTTPS
certificate. Certificates from this chain are not publicly trusted by browsers
or operating systems by default.
