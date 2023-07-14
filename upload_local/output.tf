output "relative_path" {
  value       = jsondecode(azapi_resource_action.get_resource_upload_url.output).relativePath
  description = "relative path that can feed to Azure Spring Apps deployment or build."
}