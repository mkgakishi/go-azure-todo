# Temporary fix: Enable public access for diagnostics
# Add this to main.tf temporarily to test connectivity

# In azurerm_cosmosdb_account.main, change:
# public_network_access_enabled = true  # temporary for testing

# In azurerm_redis_cache.main, change:
# public_network_access_enabled = true  # temporary for testing

# After confirming app works, change back to false and rely on private endpoints
