data "google_project" "project" {
}

resource "google_service_account" "default" {
  for_each     = { for cluster in var.clusters : cluster.name => cluster }
  account_id   = "gke-${each.value.name}-sa"
  display_name = "GKE ${each.value.name} Service Account"
}

resource "google_container_cluster" "cluster" {
  for_each = { for cluster in var.clusters : cluster.name => cluster }
  name     = each.value.name
  location = each.value.location


  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  node_config {
    tags = var.network_tags
  }
  dynamic "workload_identity_config" {
    for_each = var.workload_identity == false ? [] : [var.workload_identity]
    content {
      workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
    }
  }
}

resource "google_container_node_pool" "nodepool" {
  for_each   = { for cluster in var.clusters : cluster.name => cluster }
  name       = "node-pool"
  location   = each.value.location
  cluster    = google_container_cluster.cluster[each.key].name
  node_count = each.value.node_count

  node_config {
    machine_type = each.value.machine_type
    tags         = var.network_tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default[each.key].email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

  }

}
