resource "azurerm_resource_group" "main" {
  name     = "cloud-observability-dev-rg"
  location = "West India"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "cloudobs-law-dev"
  location            = "Central India"
  resource_group_name = azurerm_resource_group.main.name

  sku               = "PerGB2018"
  retention_in_days = 30
  daily_quota_gb    = 0.1
}

resource "azurerm_application_insights" "main" {
  name                = "cloudobs-appinsights-dev"
  location            = "Central India"
  resource_group_name = azurerm_resource_group.main.name

  workspace_id = azurerm_log_analytics_workspace.main.id

  application_type = "web"
}

resource "azurerm_eventgrid_topic" "main" {
  name                = "cloudobs-events-dev"
  location            = "Central India"
  resource_group_name = azurerm_resource_group.main.name

  input_schema = "EventGridSchema"
}

resource "azurerm_storage_account" "function_storage" {
  name                = "cloudobsfuncdevsa"
  resource_group_name = azurerm_resource_group.main.name
  location            = "Central India"

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
}