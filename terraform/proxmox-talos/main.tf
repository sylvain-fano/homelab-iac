# -----------------------------------------------------------------------------
# Talos ISO (pre-downloaded via SSH due to API token privilege separation)
# To update: ssh root@proxmox "cd /var/lib/vz/template/iso && wget -O talos-<version>-amd64.iso 'https://github.com/siderolabs/talos/releases/download/<version>/metal-amd64.iso'"
# -----------------------------------------------------------------------------

locals {
  talos_iso_path = "${var.talos_iso_storage}:iso/talos-${var.talos_version}-amd64.iso"
}

# -----------------------------------------------------------------------------
# Control Plane VMs
# -----------------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "control_plane" {
  for_each = { for idx, cp in var.control_planes : cp.name => cp }

  name        = each.value.name
  description = "Talos Linux Control Plane - ${var.cluster_name}"
  tags        = ["talos", "kubernetes", "control-plane"]

  node_name = each.value.target_node
  vm_id     = 200 + index(var.control_planes, each.value)

  # Machine type
  machine = "q35"
  bios    = "seabios"

  # CPU
  cpu {
    cores   = each.value.cpu_cores
    sockets = 1
    type    = "host"
  }

  # Memory
  memory {
    dedicated = each.value.memory_mb
  }

  # Boot from ISO
  cdrom {
    file_id   = local.talos_iso_path
    interface = "ide2"
  }

  # System disk
  disk {
    datastore_id = var.vm_storage
    interface    = "scsi0"
    size         = each.value.disk_gb
    file_format  = "raw" # Raw format for better performance on local storage
    discard      = "on"
  }

  # Network
  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # QEMU agent disabled - Talos doesn't have qemu-guest-agent
  agent {
    enabled = false
  }

  # Boot order - only disk, ISO not needed after install
  boot_order = ["scsi0"]

  # Start on create
  started = true

  # Cloud-init is not used with Talos (it uses machine config)
  # Network configuration will be done via talosctl

  lifecycle {
    ignore_changes = [
      cdrom, # ISO can be detached after install
    ]
  }
}

# -----------------------------------------------------------------------------
# Outputs for Talos configuration
# -----------------------------------------------------------------------------

output "control_plane_ips" {
  description = "Control plane IP addresses for talosctl"
  value       = { for name, cp in var.control_planes : name => cp.ip_address }
}
