terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.58.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.6.0"
    }
  }
}

provider "azapi" {
  # Configuration options
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


resource "azurerm_spring_cloud_app" "terraform_app" {
  name                = "app-terraform"
  resource_group_name = var.resource_group_name
  service_name        = var.service_name
  is_public           = true

}

module "upload_binary" {
  source = "./upload_local"

  resource_group_name = var.resource_group_name
  location            = "eastus"

  resource_id = azurerm_spring_cloud_app.terraform_app.id
  local_path = var.local_path
}

resource "azapi_resource" "deployment" {
  type      = "Microsoft.AppPlatform/Spring/apps/deployments@2022-12-01"
  name      = "default"
  parent_id = azurerm_spring_cloud_app.terraform_app.id

  body = jsonencode({
    properties = {
      active = true
      source = {
        type           = "Jar"
        relativePath   = module.upload_binary.relative_path
        runtimeVersion = "Java_11"
      }
      deploymentSettings = {
        resourceRequests = {
          cpu    = "1"
          memory = "2Gi"
        }
      }

    }
    sku = {
      capacity = 1
      name     = "S0"
      tier     = "Standard"
    }
  })

  depends_on = [module.upload_binary]
}