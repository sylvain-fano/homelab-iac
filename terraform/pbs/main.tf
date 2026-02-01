# -----------------------------------------------------------------------------
# Proxmox Backup Server LXC Container
# -----------------------------------------------------------------------------
# PBS installed on Debian 12 LXC with datastore mounted from NFS
# -----------------------------------------------------------------------------

# Download Debian 12 template if not present
resource "proxmox_virtual_environment_download_file" "debian_template" {
  content_type = "vztmpl"
  datastore_id = var.template_storage
  node_name    = var.pbs_target_node
  url          = "https://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
  file_name    = "debian-12-standard_12.7-1_amd64.tar.zst"
}

# PBS LXC Container
resource "proxmox_virtual_environment_container" "pbs" {
  description = "Proxmox Backup Server"
  tags        = ["pbs", "backup", "infra"]

  node_name = var.pbs_target_node

  # Privileged container (required for NFS datastore access)
  unprivileged = false

  # Start on boot
  start_on_boot = true

  # Operating System
  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_template.id
    type             = "debian"
  }

  # Initialization
  initialization {
    hostname = var.pbs_hostname

    # DHCP
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # DNS
    dns {
      servers = var.dns_servers
    }
  }

  # CPU
  cpu {
    cores = var.pbs_cpu_cores
  }

  # Memory
  memory {
    dedicated = var.pbs_memory_mb
  }

  # Root disk
  disk {
    datastore_id = var.lxc_storage
    size         = var.pbs_disk_gb
  }

  # Mount point for PBS datastore - added manually after creation
  # (bind mounts require root@pam, not API token)
  # pct set <CTID> -mp0 /mnt/pve/backups,mp=/mnt/datastore,shared=1

  # Network
  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  # Features - nesting not allowed via API for privileged containers
  # Add manually if needed: pct set <ID> -features nesting=1

  # Console
  console {
    type = "console"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "pbs_id" {
  description = "PBS container ID"
  value       = proxmox_virtual_environment_container.pbs.vm_id
}

output "pbs_hostname" {
  description = "PBS hostname"
  value       = var.pbs_hostname
}

output "next_steps" {
  description = "Post-deployment instructions"
  value       = <<-EOT

    PBS LXC deployed! Next steps:

    1. Get the container IP:
       pct exec ${proxmox_virtual_environment_container.pbs.vm_id} -- ip a

    2. SSH into the container:
       ssh root@<IP>

    3. Install PBS:
       wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
       echo "deb http://download.proxmox.com/debian/pbs bookworm pbs-no-subscription" > /etc/apt/sources.list.d/pbs.list
       apt update && apt install -y proxmox-backup-server

    4. Access PBS web UI:
       https://<IP>:8007

    5. Create datastore in PBS:
       proxmox-backup-manager datastore create homelab /mnt/datastore

    6. Add PBS storage in Proxmox:
       Datacenter → Storage → Add → Proxmox Backup Server
  EOT
}
