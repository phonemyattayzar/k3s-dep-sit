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

The root and child Applications point to
`git@github.com:phonemyattayzar/k3s-dep-sit.git` on branch `main`. Ensure this
checkout is pushed to that repository and Argo CD has an SSH deploy key or
repository credential configured before bootstrapping.

After pushing the repository, bootstrap once with:

```powershell
kubectl apply -f .\argocd\root-app.yaml
```

The namespace resources app ignores only the data field of the runtime-generated
`ecr-pull-secret` in the `default` and `sar-mel` namespaces, so Argo CD won’t
replace refreshed ECR tokens with the placeholder stored in Git.

## Sar Mel applications

The root app also creates manually synced `sar-mel-backend` and
`sar-mel-frontend` Applications. Sync `namespace-resources` first so the
`sar-mel` namespace and ECR pull-secret placeholder exist. The ECR refresher
then updates that pull secret; its token refreshes every six hours.

Before syncing the backend, create `sar-mel-backend-secrets` in namespace
`sar-mel` through your secret manager. It must contain `SECRET_KEY`,
`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, and `DATABASE_URL`. Set the
database values to the existing PostgreSQL release (`postgres.postgres.svc`,
database `appdb`, user `appuser`). URL-encode special characters in the
credentials used in `DATABASE_URL`. Secret values must not be committed in
plain text. Configure the source in SOPS or an External Secrets controller if
you want Argo CD to manage that Secret declaratively; neither secret controller
is installed by this repository today.

The frontend is exposed at `https://sar-mel.dat.com` through the existing
Envoy Gateway wildcard certificate. Its NGINX config proxies `/api/` and
`/static/` to the backend Service inside the `sar-mel` namespace. The backend
Service itself is internal-only.
