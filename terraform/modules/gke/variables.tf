variable "clusters" {
  type = list(object({
    name         = string
    location     = string
    machine_type = string
    node_count   = number
  }))
}

variable "network_tags" {
  type    = list(string)
  default = []
}

variable "workload_identity" {
  type    = bool
  default = false
}
