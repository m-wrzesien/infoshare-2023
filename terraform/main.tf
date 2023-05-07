terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
  required_version = "~> 1.4.0"
}

provider "google" {
  project = var.project
}

resource "google_service_account" "argocd-account" {
  account_id   = "argocd-service-account-id"
  display_name = "ArgoCD Service Account"
}

resource "google_project_iam_binding" "argo-binding" {
  project = var.project
  role    = "roles/container.developer"

  members = [
    "serviceAccount:${google_service_account.argocd-account.email}",
  ]
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.argocd-account.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[argocd/argocd-application-controller]",
    "serviceAccount:${var.project}.svc.id.goog[argocd/argocd-repo-server]"
  ]
}

# Allow access from Internet to k8s nodePorts, as those are used for deployment of our apps
resource "google_compute_firewall" "allow-to-node-ports" {
  name      = "allow-to-node-ports"
  network   = "default"
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
  target_tags   = var.network_tags
  source_ranges = ["0.0.0.0/0"]
}

module "gke" {
  source = "./modules/gke"

  clusters     = var.k8s-clusters
  network_tags = var.network_tags
  # Use in GCP environments so K8S service account can be used as a GCP service account
  # https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity
  workload_identity = true
}
