output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = var.cluster_name
}

output "cluster_vip" {
  description = "Kubernetes API VIP"
  value       = var.cluster_vip
}

output "control_plane_nodes" {
  description = "Control plane node details"
  value = {
    for cp in var.control_planes : cp.name => {
      ip_address  = cp.ip_address
      target_node = cp.target_node
      vm_id       = 100 + index(var.control_planes, cp)
    }
  }
}

output "talos_version" {
  description = "Deployed Talos version"
  value       = var.talos_version
}

output "next_steps" {
  description = "Next steps after VM creation"
  value       = <<-EOT
    VMs created. Next steps:

    1. Wait for VMs to boot from Talos ISO

    2. Generate Talos secrets:
       cd ../talos
       talosctl gen secrets -o secrets.yaml

    3. Generate machine configs:
       talosctl gen config ${var.cluster_name} https://${var.cluster_vip}:6443 \
         --with-secrets secrets.yaml \
         --output-dir .

    4. Apply machine configs to each node:
       %{for cp in var.control_planes~}
       talosctl apply-config --insecure --nodes ${cp.ip_address} --file controlplane.yaml
       %{endfor~}

    5. Bootstrap the cluster:
       talosctl bootstrap --nodes ${var.control_planes[0].ip_address}

    6. Get kubeconfig:
       talosctl kubeconfig --nodes ${var.cluster_vip}
  EOT
}
