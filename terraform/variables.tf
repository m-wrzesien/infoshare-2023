variable "project" {
  type    = string
  default = "esky-infoshare-2023"
}

variable "k8s-clusters" {
  type = list(object({
    location     = string
    machine_type = string
    name         = string
    node_count   = number
  }))
  default = [
    {
      location     = "europe-central2-a"
      machine_type = "e2-medium"
      name         = "k8s-operator"
      node_count   = 2
    },
    {
      location     = "europe-central2-b"
      machine_type = "e2-medium"
      name         = "k8s-staging"
      node_count   = 1
    },
    {
      location     = "europe-central2-c"
      machine_type = "e2-medium"
      name         = "k8s-pro"
      node_count   = 1
  }]

}

variable "network_tags" {
  type    = list(string)
  default = ["k8s-infoshare-2023"]
}
