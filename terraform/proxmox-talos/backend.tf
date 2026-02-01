# GitLab HTTP backend for Terraform state
# Replace YOUR_PROJECT_ID with your GitLab project ID
#
# Configure via environment variables:
#   TF_HTTP_USERNAME=<gitlab-username>
#   TF_HTTP_PASSWORD=<gitlab-pat-with-api-scope>

terraform {
  backend "http" {
    address = "https://gitlab.com/api/v4/projects/YOUR_PROJECT_ID/terraform/state/proxmox-talos"
  }
}

# Alternatively, use local backend (uncomment below and comment above):
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }
