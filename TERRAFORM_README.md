# Azure Terraform Deployment

This directory contains Terraform configuration for deploying the Go Todo application to Azure Container Apps with private access to MongoDB Cosmos DB and Azure Redis Cache.

## Architecture

The infrastructure includes:

- **Virtual Network** with dedicated subnets for Container Apps and Private Endpoints
- **Azure Cosmos DB** (MongoDB API) with serverless configuration and private endpoint
- **Azure Redis Cache** with private endpoint and TLS enabled
- **Azure Container Apps** with VNet integration
- **Private DNS Zones** for secure name resolution
- **Container Registry** for hosting your Docker images
- **Log Analytics Workspace** for monitoring and diagnostics

All database resources (Cosmos DB and Redis) are configured with **private endpoints only** and are not accessible from the public internet.

## Prerequisites

1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
2. [Terraform](https://www.terraform.io/downloads.html) >= 1.0 installed
3. Azure subscription with appropriate permissions
4. Docker image of your application (pushed to ACR or another registry)

## Setup

1. **Login to Azure:**
   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

2. **Create terraform.tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars` with your desired values.

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Building and Pushing Your Docker Image

After infrastructure is created, build and push your application image:

```bash
# Get ACR login server from Terraform output
$ACR_NAME = terraform output -raw container_registry_login_server

# Login to ACR
az acr login --name $ACR_NAME

# Build and push your image
docker build -t ${ACR_NAME}/go-todo-app:latest .
docker push ${ACR_NAME}/go-todo-app:latest

# Update terraform.tfvars with the new image
# container_image = "<acr-name>.azurecr.io/go-todo-app:latest"

# Apply changes
terraform apply
```

## Accessing Your Application

After deployment, get the application URL:

```bash
terraform output container_app_url
```

Visit `https://<container_app_url>` to access your application.

## Private Network Configuration

The infrastructure is configured with the following security features:

- **Cosmos DB**: Public access disabled, accessible only via private endpoint
- **Redis Cache**: Public access disabled, accessible only via private endpoint
- **Container Apps**: Deployed in a dedicated subnet with VNet integration
- **Private DNS Zones**: Automatic DNS resolution for private endpoints

## Environment Variables

The Container App is automatically configured with:

- `MONGODB_URI`: Connection string to Cosmos DB
- `MONGODB_DATABASE`: Database name
- `REDIS_HOST`: Redis hostname (private endpoint)
- `REDIS_PORT`: Redis SSL port (6380)
- `REDIS_PASSWORD`: Redis access key (stored as secret)
- `ENVIRONMENT`: Deployment environment

## Monitoring

Access logs and metrics through:

- Azure Portal → Container Apps → Your app → Monitoring
- Log Analytics Workspace (ID available in Terraform outputs)

## Cost Optimization

- Cosmos DB is configured as **serverless** (pay per request)
- Redis Cache uses **Basic** tier by default (adjust in terraform.tfvars)
- Container Apps scale from **1 to 3** replicas by default

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Customization

### Using Internal Load Balancer

For fully private access (no public endpoint):

```hcl
# In terraform.tfvars
internal_load_balancer_enabled = true
ingress_external_enabled = false
```

### Scaling Configuration

Adjust in terraform.tfvars:

```hcl
min_replicas = 2
max_replicas = 10
container_cpu = 1.0
container_memory = "2Gi"
```

### Redis Configuration

For production, consider Standard or Premium:

```hcl
redis_sku_name = "Standard"
redis_capacity = 1
redis_family = "C"
```

## Troubleshooting

### Container App not starting

Check logs:
```bash
az containerapp logs show --name <app-name> --resource-group <rg-name> --follow
```

### Cannot connect to Cosmos DB or Redis

Verify private endpoint DNS resolution from Container App:
- Ensure private DNS zones are linked to the VNet
- Check that Container Apps subnet is in the same VNet

### Authentication errors

Verify connection strings and credentials in outputs:
```bash
terraform output -json
```

## Security Best Practices

1. Never commit `terraform.tfvars` or `.tfstate` files to version control
2. Use Azure Key Vault for storing sensitive values in production
3. Enable Azure Monitor alerts for your resources
4. Regularly update the Terraform provider version
5. Use managed identities instead of connection strings when possible

## Support

For issues or questions:
- Check Azure Container Apps documentation
- Review Terraform Azure provider documentation
- Verify network connectivity and DNS resolution
