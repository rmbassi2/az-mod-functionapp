# Create a storage account for the Function App
resource "azurerm_storage_account" "sa" {
  name                     = "functionappstorage${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an App Service Plan for the Function App
resource "azurerm_app_service_plan" "asp" {
  name                = "functionapp-service-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Create the Function App
resource "azurerm_linux_function_app" "fa" {
  name                       = "functionapp${random_string.function_suffix.result}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  os_type                    = "linux"
  runtime_stack              = "python"
  version                    = "~3"
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

# Generate random strings for unique resource names
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "function_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Output the Function App URL
output "function_app_url" {
  value = azurerm_linux_function_app.fa.default_hostname
}
