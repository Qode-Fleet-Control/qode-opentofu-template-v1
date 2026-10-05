output "name" {
  description = "Generated resource name."
  value       = random_pet.name.id
}

output "unique_name" {
  description = "Generated name plus a random hex suffix."
  value       = "${random_pet.name.id}-${random_id.suffix.hex}"
}

output "manifest_path" {
  description = "Where the rendered manifest is written on apply."
  value       = local_file.manifest.filename
}
