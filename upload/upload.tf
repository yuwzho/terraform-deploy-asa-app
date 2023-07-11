terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "1.6.0"
    }
  }
}

locals {
  resource_types = regex("providers/([^/]+)/([^/]+)(?:/[^/]+){1}/([^/]+)", var.resource_id)
  script         = file("${path.module}/upload.sh")
}

resource "null_resource" "resource" {
  triggers = {
    source_url  = var.source_url
    resource_id = var.resource_id
  }
}

resource "azapi_resource_action" "get_resource_upload_url" {
  type                   = format("%s@2022-12-01", join("/", local.resource_types))
  resource_id            = var.resource_id
  action                 = "getResourceUploadUrl"
  response_export_values = ["*"]

  lifecycle {
    replace_triggered_by = [
      null_resource.resource
    ]
  }
}

resource "azurerm_resource_deployment_script_azure_cli" "upload" {
  name                = "upload-binary"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "2.41.0"
  retention_interval  = "PT1H"
  timeout             = "PT10M"

  cleanup_preference = "OnSuccess"

  environment_variable {
    name  = "source_url"
    value = var.source_url
  }
  environment_variable {
    name  = "upload_url"
    value = jsondecode(azapi_resource_action.get_resource_upload_url.output).uploadUrl
  }
  environment_variable {
    name  = "auth_header"
    value = var.auth_header
  }

  script_content = local.script

  lifecycle {
    replace_triggered_by = [
      null_resource.resource
    ]
  }
}