locals {
  prefix = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "opentofu"
  }
}

resource "random_pet" "name" {
  length    = var.pet_length
  prefix    = local.prefix
  separator = "-"
}

resource "random_id" "suffix" {
  byte_length = 4

  keepers = {
    pet = random_pet.name.id
  }
}

# A stand-in for "do something once per name" (a provisioner, an external call ...).
resource "null_resource" "announce" {
  triggers = {
    name = random_pet.name.id
  }
}

resource "local_file" "manifest" {
  filename        = "${path.module}/out/manifest.json"
  file_permission = "0644"
  content = jsonencode({
    name   = random_pet.name.id
    suffix = random_id.suffix.hex
    tags   = local.tags
  })
}
