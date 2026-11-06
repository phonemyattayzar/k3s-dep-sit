# Argo CD app-of-apps bootstrap

`root-app.yaml` points Argo CD at the child Applications in `argoapps/`. The
app-of-apps manages Kubernetes resources from `kustomize/overlay/production`.
Argo CD, cert-manager, and Envoy Gateway are platform components and are
installed or upgraded manually from their Helm charts and values files under
`helm/`; they are intentionally excluded from Argo CD sync.

Install or upgrade those three Helm releases before syncing the production
overlay. The overlay contains their Gateway API and certificate custom
resources, which require the corresponding CRDs to exist. For example:

```powershell
helm upgrade --install eg oci://docker.io/envoyproxy/gateway-helm --namespace envoy-gateway-system --create-namespace --version 1.9.3 --values .\helm\envoy-gateway\values.yaml
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version 1.14.4 --values .\helm\cert-manager\values.yaml
helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace --version 6.7.1 --values .\helm\argocd\values.yaml
```

Add the `jetstack` and `argo` Helm repositories before running the commands.
The Envoy Gateway chart is pulled from OCI and needs no repository setup.
Install Gateway API v1.6.1 standard CRDs before syncing the production overlay;
they are cluster-scoped prerequisites and are upgraded separately from the
Envoy Gateway Helm release.

Before bootstrapping, replace every `https://github.com/REPLACE_ME/k3s-dep-dat.git`
with the actual Git remote, and change `targetRevision: main` if the repository
uses another branch. This checkout currently has no Git remote, so the root
Application is intentionally not applied.

After pushing the repository and updating the URLs, bootstrap once with:

```powershell
kubectl apply -f .\argocd\root-app.yaml
```

The namespace resources app ignores only the data field of the runtime-generated
`default/ecr-pull-secret`, so Argo CD won’t replace its refreshed token with the
placeholder stored in Git.
