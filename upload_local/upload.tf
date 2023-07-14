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
    local_path  = var.local_path
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

resource "terraform_data" "upload" {
  provisioner "local-exec" {

    command = "./upload.sh"
    working_dir = path.module
    interpreter = [ "bash", "-c" ]

    environment = {
      local_path = var.local_path
      upload_url = jsondecode(azapi_resource_action.get_resource_upload_url.output).uploadUrl
    }

  }
  lifecycle {
    replace_triggered_by = [
      null_resource.resource
    ]
  }
}