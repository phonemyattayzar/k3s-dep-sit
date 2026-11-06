# Envoy Gateway cert-manager CA chain

This directory defines a private certificate chain for the Envoy Gateway TLS
listener: self-signed root CA -> intermediate CA -> Gateway leaf certificate.
The Helm chart configuration is separate in `helm/envoy-gateway/values.yaml`.

## Prerequisites and apply order

Install cert-manager first, including its CRDs. The default cert-manager
Cluster Resource Namespace is `cert-manager`; if your installation overrides
that setting, update the namespaces and Secret references in
`envoy-gateway-ca-chain.yaml` accordingly.

The leaf certificate is for `*.dat.com`. It covers one-level subdomains such as
`app.dat.com`, but not `dat.com` itself or deeper names such as
`api.dev.dat.com`. Add those names to `dnsNames` if they must also be served.
Apply the CA resources and wait for the leaf certificate before applying the
Gateway resources:

```powershell
kubectl apply -k .\kustomize\cert-manager
kubectl wait --for=condition=Ready certificate/envoy-gateway-tls -n envoy-gateway-system --timeout=10m
kubectl apply -k .\kustomize\envoy-gateway
```

Issuance is asynchronous. Check the CA issuers and certificates with:

```powershell
kubectl get clusterissuer
kubectl get certificate -A
```

## PKI note

The root CA private key is stored in a Kubernetes Secret. For production, use
an offline or externally managed root CA where possible, and establish backup,
rotation, and trust distribution procedures. Certificates from this chain are
private and are not trusted by browsers or operating systems by default.
