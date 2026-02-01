# Provider configuration
# Authentication via environment variable: PROXMOX_VE_API_TOKEN
# Format: root@pam!tokenid=secret

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure

  ssh {
    agent    = true
    username = "root"
  }
}
