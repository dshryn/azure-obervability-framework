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

resource "azurerm_service_plan" "function_plan" {
  name                = "cloudobs-functions-plan"
  location            = "Central India"
  resource_group_name = azurerm_resource_group.main.name

  os_type  = "Linux"
  sku_name = "Y1"
}

resource "azurerm_linux_function_app" "main" {
  name                = "cloudobs-functions-dev"
  location            = "Central India"
  resource_group_name = azurerm_resource_group.main.name

  https_only = true

  service_plan_id = azurerm_service_plan.function_plan.id

  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
  APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.main.instrumentation_key
  APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string

  ARCHIVE_STORAGE_CONNECTION_STRING = azurerm_storage_account.archive_storage.primary_connection_string
  ARCHIVE_CONTAINER_NAME            = azurerm_storage_container.telemetry_archive.name
}
}

resource "azurerm_storage_account" "archive_storage" {
  name                     = "cloudobsarchivedevsa"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = "Central India"

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "telemetry_archive" {
  name                  = "telemetry-archive"
  storage_account_id    = azurerm_storage_account.archive_storage.id
  container_access_type = "private"
}