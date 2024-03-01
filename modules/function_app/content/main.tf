resource "azurerm_linux_function_app" "func" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = module.func_sa.name
  storage_uses_managed_identity = true
  service_plan_id            = var.app_service_plan_id

  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = var.functions_subnet_id

  app_settings = var.app_settings

  site_config {
    always_on = true
    application_insights_connection_string = module.func_ai.application_insights_connection_string
    vnet_route_all_enabled = true
    minimum_tls_version = 1.2
    application_insights_key = module.func_ai.instrumentation_key    
  }
}