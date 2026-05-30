terraform {
  backend "azurerm" {
    resource_group_name  = "cloud-observability-dev-rg"
    storage_account_name = "cloudobsdshryn"
    container_name       = "tfstate"
    key                  = "cloud-observability-dev.tfstate"
  }
}