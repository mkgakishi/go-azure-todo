output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "container_app_url" {
  description = "URL of the deployed Container App"
  value       = azurerm_container_app.main.ingress[0].fqdn
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_connection_string" {
  description = "Cosmos DB MongoDB connection string"
  value       = azurerm_cosmosdb_account.main.primary_mongodb_connection_string
  sensitive   = true
}

output "redis_hostname" {
  description = "Redis Cache hostname"
  value       = azurerm_redis_cache.main.hostname
}

output "redis_ssl_port" {
  description = "Redis Cache SSL port"
  value       = azurerm_redis_cache.main.ssl_port
}

output "redis_primary_key" {
  description = "Redis Cache primary access key"
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

output "container_registry_login_server" {
  description = "Container Registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_admin_username" {
  description = "Container Registry admin username"
  value       = azurerm_container_registry.main.admin_username
}

output "container_registry_admin_password" {
  description = "Container Registry admin password"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "docker_build_push_commands" {
  description = "Commands to build and push Docker image to ACR"
  value = <<-EOT
    # Login to Azure Container Registry
    az acr login --name ${azurerm_container_registry.main.name}
    
    # Or use Docker login
    docker login ${azurerm_container_registry.main.login_server} -u ${azurerm_container_registry.main.admin_username} -p <password>
    
    # Build the Docker image
    docker build -t ${azurerm_container_registry.main.login_server}/${var.docker_image_name}:${var.docker_image_tag} .
    
    # Push the image to ACR
    docker push ${azurerm_container_registry.main.login_server}/${var.docker_image_name}:${var.docker_image_tag}
    
    # Update Container App to use the new image
    terraform apply
  EOT
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "container_apps_subnet_id" {
  description = "Container Apps subnet ID"
  value       = azurerm_subnet.container_apps.id
}

output "private_endpoints_subnet_id" {
  description = "Private endpoints subnet ID"
  value       = azurerm_subnet.private_endpoints.id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}
