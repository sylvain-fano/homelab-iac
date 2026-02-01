# Homelab Infrastructure as Code

Production-grade Kubernetes homelab with Proxmox, Talos Linux, and GitOps.

## Overview

This repository contains the Terraform and Ansible code to provision and manage a homelab infrastructure running on Proxmox VE. The setup includes:

- **Talos Linux** - Immutable Kubernetes OS for control plane nodes
- **Proxmox Backup Server** - LXC container for VM/CT backups
- **Pi-hole** - DNS server with ad-blocking
- **Monitoring** - Node exporter for Prometheus metrics

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │           Proxmox Cluster               │
                    │  ┌───────────────┐ ┌───────────────┐   │
                    │  │   proxmox-1   │ │   proxmox-2   │   │
                    │  │  (primary)    │ │  (secondary)  │   │
                    │  └───────┬───────┘ └───────┬───────┘   │
                    │          │                 │           │
                    │  ┌───────┴─────────────────┴───────┐   │
                    │  │                                 │   │
                    │  │  ┌─────────────────────────┐   │   │
                    │  │  │   Talos K8s Cluster     │   │   │
                    │  │  │  ┌─────┐┌─────┐┌─────┐ │   │   │
                    │  │  │  │cp-1 ││cp-2 ││cp-3 │ │   │   │
                    │  │  │  └─────┘└─────┘└─────┘ │   │   │
                    │  │  │       VIP: .200        │   │   │
                    │  │  └─────────────────────────┘   │   │
                    │  │                                 │   │
                    │  │  ┌─────────┐  ┌─────────┐      │   │
                    │  │  │  PBS    │  │ Pi-hole │      │   │
                    │  │  │  .5     │  │  .253   │      │   │
                    │  │  └─────────┘  └─────────┘      │   │
                    │  │                                 │   │
                    │  └─────────────────────────────────┘   │
                    └─────────────────────────────────────────┘
```

## Prerequisites

- Proxmox VE 8.x cluster (2 nodes recommended)
- Terraform >= 1.5.0
- Ansible >= 2.15
- API token with appropriate Proxmox privileges

### Proxmox API Token

Create an API token for Terraform:

```bash
# On Proxmox node
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role Administrator
pveum user token add terraform@pve terraform-token --privsep=0
```

Export the token:

```bash
export PROXMOX_VE_API_TOKEN="terraform@pve!terraform-token=your-secret-token"
```

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/sylvain-fano/homelab-iac.git
cd homelab-iac

# Copy example files
cp terraform/proxmox-talos/terraform.tfvars.example terraform/proxmox-talos/terraform.tfvars
cp terraform/pbs/terraform.tfvars.example terraform/pbs/terraform.tfvars
cp terraform/pihole/terraform.tfvars.example terraform/pihole/terraform.tfvars
cp ansible/inventory/hosts.yaml.example ansible/inventory/hosts.yaml
```

### 2. Customize variables

Edit each `terraform.tfvars` and `hosts.yaml` with your network configuration.

### 3. Deploy Talos VMs

```bash
cd terraform/proxmox-talos
terraform init
terraform plan
terraform apply
```

### 4. Deploy PBS (optional)

```bash
cd ../pbs
terraform init
terraform apply
```

### 5. Deploy Pi-hole (optional)

```bash
cd ../pihole
terraform init
terraform apply
```

## Directory Structure

```
homelab-iac/
├── terraform/
│   ├── proxmox-talos/     # Talos K8s control plane VMs
│   ├── pbs/               # Proxmox Backup Server LXC
│   └── pihole/            # Pi-hole DNS LXC
└── ansible/
    ├── inventory/         # Host definitions
    ├── playbooks/         # Automation playbooks
    └── roles/             # Reusable roles
```

## Configuration

### Network

Default network configuration uses `192.168.1.0/24`. Update the following variables in `terraform.tfvars`:

| Variable | Default | Description |
|----------|---------|-------------|
| `proxmox_endpoint` | `https://192.168.1.2:8006` | Proxmox API URL |
| `cluster_vip` | `192.168.1.200` | K8s API virtual IP |
| `control_planes[*].ip_address` | `.201-.203` | Control plane IPs |
| `pihole_ip` | `192.168.1.253` | DNS server IP |

### Storage

| Variable | Default | Description |
|----------|---------|-------------|
| `vm_storage` | `local-lvm` | VM disk storage |
| `lxc_storage` | `local-lvm` | LXC disk storage |
| `talos_iso_storage` | `local` | ISO storage location |

### Terraform State

By default, state is stored locally. For team use, configure a remote backend in `backend.tf`:

```hcl
terraform {
  backend "http" {
    address = "https://gitlab.com/api/v4/projects/YOUR_PROJECT_ID/terraform/state/proxmox-talos"
  }
}
```

## Ansible Playbooks

### Install node_exporter

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/node_exporter.yaml
```

### Install QEMU guest agent

```bash
ansible-playbook -i inventory/hosts.yaml playbooks/qemu_guest_agent.yaml
```

### Deploy TLS certificates

```bash
ansible-playbook -i inventory/hosts.yaml playbooks/deploy_certs.yaml
```

## Post-Deployment

After Talos VMs are created, follow these steps to bootstrap Kubernetes:

1. Generate Talos secrets:
   ```bash
   talosctl gen secrets -o secrets.yaml
   ```

2. Generate machine configs:
   ```bash
   talosctl gen config homelab https://192.168.1.200:6443 \
     --with-secrets secrets.yaml \
     --output-dir .
   ```

3. Apply configs to each node:
   ```bash
   talosctl apply-config --insecure --nodes 192.168.1.201 --file controlplane.yaml
   talosctl apply-config --insecure --nodes 192.168.1.202 --file controlplane.yaml
   talosctl apply-config --insecure --nodes 192.168.1.203 --file controlplane.yaml
   ```

4. Bootstrap the cluster:
   ```bash
   talosctl bootstrap --nodes 192.168.1.201
   ```

5. Get kubeconfig:
   ```bash
   talosctl kubeconfig --nodes 192.168.1.200
   ```

## Related Resources

- [Medium Article: Building a Production-Grade Kubernetes Homelab](https://medium.com/@sylvain.fano)
- [Talos Linux Documentation](https://www.talos.dev/docs/)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)

## License

MIT License - see [LICENSE](LICENSE) for details.
