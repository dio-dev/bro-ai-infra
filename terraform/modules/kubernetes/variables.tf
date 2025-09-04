variable "environment" {
  description = "Environment name (prod, stage)"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet for GKE cluster"
  type        = string
}

variable "pods_secondary_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "Name of the secondary range for services"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the GKE master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 10
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size" {
  description = "Disk size for GKE nodes in GB"
  type        = number
  default     = 50
}

variable "node_disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-standard"
}

variable "use_preemptible_nodes" {
  description = "Whether to use preemptible nodes"
  type        = bool
  default     = false
}

variable "release_channel" {
  description = "Release channel for GKE cluster"
  type        = string
  default     = "STABLE"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Release channel must be one of: RAPID, REGULAR, STABLE."
  }
}

variable "min_cpu_cores" {
  description = "Minimum CPU cores for cluster autoscaling"
  type        = number
  default     = 1
}

variable "max_cpu_cores" {
  description = "Maximum CPU cores for cluster autoscaling"
  type        = number
  default     = 100
}

variable "min_memory_gb" {
  description = "Minimum memory in GB for cluster autoscaling"
  type        = number
  default     = 1
}

variable "max_memory_gb" {
  description = "Maximum memory in GB for cluster autoscaling"
  type        = number
  default     = 400
}

variable "node_taints" {
  description = "List of node taints"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
} 