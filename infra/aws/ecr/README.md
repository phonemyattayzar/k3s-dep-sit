# ECR pull role

The `k3s-dep-dat-ecr-pull` EC2 role and instance profile are attached to the
k3s node `i-08136987a64c2cbdc`. Its policy permits ECR token retrieval and image
pulls from the `k3s-dep-dat` repository only. The ECR authorization token is
short-lived; the Kustomize credential refresher rotates the Kubernetes pull
Secret every six hours. The current Secret is created in `default`; add a
matching Secret and service account reference in each application namespace
that needs to pull private images.

The repository URI is
`051131628511.dkr.ecr.ap-southeast-1.amazonaws.com/k3s-dep-dat`.

The trust and permission policies used to create the role are kept here for
review. AWS resources are in account `051131628511`, region
`ap-southeast-1`.
