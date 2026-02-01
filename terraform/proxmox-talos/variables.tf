# -----------------------------------------------------------------------------
# Proxmox Connection
# -----------------------------------------------------------------------------

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL (e.g., https://proxmox.homelab.local:8006)"
  type        = string
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Talos VMs Configuration
# -----------------------------------------------------------------------------

variable "talos_version" {
  description = "Talos Linux version to deploy"
  type        = string
  default     = "v1.9.5"
}

variable "talos_iso_storage" {
  description = "Proxmox storage for Talos ISO"
  type        = string
  default     = "local"
}

variable "control_planes" {
  description = "Control plane nodes configuration"
  type = list(object({
    name        = string
    target_node = string
    ip_address  = string
    gateway     = string
    cpu_cores   = optional(number, 2)
    memory_mb   = optional(number, 4096)
    disk_gb     = optional(number, 20)
  }))
  default = [
    {
      name        = "talos-cp-1"
      target_node = "proxmox-node-1"
      ip_address  = "192.168.1.201"
      gateway     = "192.168.1.1"
    },
    {
      name        = "talos-cp-2"
      target_node = "proxmox-node-2"
      ip_address  = "192.168.1.202"
      gateway     = "192.168.1.1"
    },
    {
      name        = "talos-cp-3"
      target_node = "proxmox-node-1"
      ip_address  = "192.168.1.203"
      gateway     = "192.168.1.1"
    },
  ]
}

variable "cluster_vip" {
  description = "Virtual IP for Kubernetes API (used by kube-vip or keepalived)"
  type        = string
  default     = "192.168.1.200"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "talos-homelab"
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------

variable "network_bridge" {
  description = "Proxmox network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------

variable "vm_storage" {
  description = "Proxmox storage for VM disks"
  type        = string
  default     = "local-lvm"
}
