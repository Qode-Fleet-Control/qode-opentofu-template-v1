terraform {
  required_version = ">= 1.9"

  # Credential-free providers only: everything here plans (and applies) with no cloud
  # account. Swap in your cloud provider when the module grows real infrastructure.
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
