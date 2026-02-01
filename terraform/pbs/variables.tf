# -----------------------------------------------------------------------------
# Proxmox Connection
# -----------------------------------------------------------------------------

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# PBS LXC Configuration
# -----------------------------------------------------------------------------

variable "pbs_target_node" {
  description = "Proxmox node to deploy PBS on"
  type        = string
  default     = "proxmox-node-1"
}

variable "pbs_hostname" {
  description = "Hostname for PBS container"
  type        = string
  default     = "pbs"
}

variable "pbs_memory_mb" {
  description = "Memory allocation in MB"
  type        = number
  default     = 2048
}

variable "pbs_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "pbs_disk_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 8
}

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------

variable "lxc_storage" {
  description = "Proxmox storage for LXC root disk"
  type        = string
  default     = "local-lvm"
}

variable "template_storage" {
  description = "Proxmox storage for LXC templates"
  type        = string
  default     = "local"
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
  default     = "vmbr0"
}

variable "dns_servers" {
  description = "DNS servers for the container"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}
