# -----------------------------------------------------------------------------
# Pi-hole LXC Container
# -----------------------------------------------------------------------------
# Pi-hole DNS + Ad-blocking on Debian 12 LXC
# -----------------------------------------------------------------------------

# Pi-hole LXC Container
resource "proxmox_virtual_environment_container" "pihole" {
  description = "Pi-hole DNS + Ad-blocking"
  tags        = ["adblock", "dns", "infra"]

  vm_id     = var.pihole_vmid
  node_name = var.pihole_target_node

  # Unprivileged container
  unprivileged = true

  # Start on boot with priority
  start_on_boot = true
  startup {
    order = "1"
  }

  # Operating System - using local template reference
  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
    type             = "debian"
  }

  # Initialization
  initialization {
    hostname = var.pihole_hostname

    # Static IP
    ip_config {
      ipv4 {
        address = "${var.pihole_ip}/24"
        gateway = var.pihole_gateway
      }
    }

    # DNS - use upstream directly (Pi-hole is the DNS server)
    dns {
      domain  = var.search_domain
      servers = ["1.1.1.1", "8.8.8.8"]
    }
  }

  # CPU
  cpu {
    cores = var.pihole_cpu_cores
  }

  # Memory
  memory {
    dedicated = var.pihole_memory_mb
    swap      = var.pihole_swap_mb
  }

  # Root disk
  disk {
    datastore_id = var.lxc_storage
    size         = var.pihole_disk_gb
  }

  # Network
  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  # Features - nesting for Docker/Podman if needed
  features {
    keyctl  = true
    nesting = true
  }

  # Console
  console {
    type = "console"
  }

  # Prevent accidental destruction
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      operating_system,
    ]
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "pihole_id" {
  description = "Pi-hole container ID"
  value       = proxmox_virtual_environment_container.pihole.vm_id
}

output "pihole_hostname" {
  description = "Pi-hole hostname"
  value       = var.pihole_hostname
}

output "pihole_ip" {
  description = "Pi-hole IP address"
  value       = var.pihole_ip
}

output "web_ui" {
  description = "Pi-hole admin URL"
  value       = "http://${var.pihole_ip}/admin"
}
