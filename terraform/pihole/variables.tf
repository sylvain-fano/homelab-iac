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
# Pi-hole LXC Configuration
# -----------------------------------------------------------------------------

variable "pihole_vmid" {
  description = "VMID for Pi-hole container"
  type        = number
  default     = 112
}

variable "pihole_target_node" {
  description = "Proxmox node to deploy Pi-hole on"
  type        = string
  default     = "proxmox-node-2"
}

variable "pihole_hostname" {
  description = "Hostname for Pi-hole container"
  type        = string
  default     = "pihole"
}

variable "pihole_memory_mb" {
  description = "Memory allocation in MB"
  type        = number
  default     = 1024
}

variable "pihole_swap_mb" {
  description = "Swap allocation in MB"
  type        = number
  default     = 512
}

variable "pihole_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "pihole_disk_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 5
}

variable "pihole_ip" {
  description = "Static IP address for Pi-hole"
  type        = string
  default     = "192.168.1.253"
}

variable "pihole_gateway" {
  description = "Gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------

variable "lxc_storage" {
  description = "Proxmox storage for LXC root disk"
  type        = string
  default     = "local-lvm"
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
  default     = "vmbr0"
}

variable "search_domain" {
  description = "DNS search domain"
  type        = string
  default     = "homelab.local"
}
