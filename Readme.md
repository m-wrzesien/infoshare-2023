# Infoshare 2023

`GitOps approach in K8S with help of ArgoCD - How to manage multiple clusters?`

Polish - `Podejście GitOpsowe w K8S z użyciem ArgoCD - Jak zarządzać wieloma klastrami?`

This repo contains all code required for the presentiation including:
* A Terraform manifests for deploying 3 clusters (directory `terraform`):
* * k8s-operator - cluster hosting Argo CD
* * k8s-staging
* * k8s-pro
* A Helm Chart for deploying Argo CD (directory `argo-cd`)
* CRD's used by Argo CD for app deployments and generation of those deployments (directory `argo-apps`)
* Simple Go app used to simulate "real" applications (directory `app`)

## Deployment
### Required software:
* argocd cli - (https://argo-cd.readthedocs.io/en/stable/cli_installation/) - required for adding K8S cluster to Argo CD
* gcloud
* helm
* kubectl
* terraform
### Steps to deploy:
1. Change variables (especially `project`) for terraform in file `variables.tf`
1. Deploy K8S clusters using `make terraform-apply`
1. Download credentials to clusters by executing for each:
    ```
    gcloud container clusters get-credentials  --project [PROJECT] --zone [ZONE] [CLUSTER_NAME]
    ```
1. Deploy Argo CD using `make argo-upgrade-install`
1. Access Argo CD UI using `make argo-portforward` and by entering https://localhost:8088 - It's by default using self-signed certificate
1. Sign in using `admin` user and `admin` password
1. Add clusters to ArgoCD using argocd cli:
    * interactively - https://argo-cd.readthedocs.io/en/stable/getting_started/#5-register-a-cluster-to-deploy-apps-to-optional
    * declaratively - example of this is commented in `values.yaml` in `clusterCredentials` - (https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters)
1. Add credentials to repository:
    * interactively - from ui https://localhost:8088/settings/repos
    * declaratively - example of this is commented in `values.yaml` in `credentialTemplates` - https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repository-credentials
1. Apply `argo-apps.yaml` from `argo-apps`:
    ```
        kubectl apply -f argo-apps/argo-apps.yaml
    ```
1. Check Argo UI https://localhost:8088