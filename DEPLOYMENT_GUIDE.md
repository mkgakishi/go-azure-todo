# Deployment Guide: Building and Pushing Docker Image to Azure Container Registry

## Prerequisites

After running `terraform apply`, you'll have an Azure Container Registry (ACR) created.

## Step 1: Get ACR Credentials

```powershell
# Get the ACR login server
$ACR_LOGIN_SERVER = terraform output -raw container_registry_login_server

# Get the ACR name (without .azurecr.io)
$ACR_NAME = $ACR_LOGIN_SERVER -replace '\.azurecr\.io',''

# Get admin password (if needed for Docker login)
$ACR_PASSWORD = terraform output -raw container_registry_admin_password
```

## Step 2: Login to Azure Container Registry

**Option A: Using Azure CLI (Recommended)**
```powershell
az acr login --name $ACR_NAME
```

**Option B: Using Docker Login**
```powershell
$ACR_USERNAME = terraform output -raw container_registry_admin_username
docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME -p $ACR_PASSWORD
```

## Step 3: Build Your Docker Image

```powershell
# Build the image with ACR tag
docker build -t ${ACR_LOGIN_SERVER}/go-todo-app:latest .

# Or with version tag
docker build -t ${ACR_LOGIN_SERVER}/go-todo-app:v1.0.0 .
```

## Step 4: Push Image to ACR

```powershell
# Push the image
docker push ${ACR_LOGIN_SERVER}/go-todo-app:latest

# If you used a version tag
docker push ${ACR_LOGIN_SERVER}/go-todo-app:v1.0.0
```

## Step 5: Update Container App (if needed)

If you want to use a different tag than "latest":

1. Update `terraform.tfvars`:
   ```hcl
   docker_image_tag = "v1.0.0"
   ```

2. Apply changes:
   ```powershell
   terraform apply
   ```

## Complete Deployment Script

Here's a complete PowerShell script to deploy after Terraform creates the infrastructure:

```powershell
# Get outputs from Terraform
$ACR_LOGIN_SERVER = terraform output -raw container_registry_login_server
$ACR_NAME = $ACR_LOGIN_SERVER -replace '\.azurecr\.io',''
$IMAGE_NAME = "go-todo-app"
$IMAGE_TAG = "latest"

Write-Host "Logging into Azure Container Registry..." -ForegroundColor Green
az acr login --name $ACR_NAME

Write-Host "Building Docker image..." -ForegroundColor Green
docker build -t ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} .

Write-Host "Pushing image to ACR..." -ForegroundColor Green
docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}

Write-Host "Updating Container App..." -ForegroundColor Green
terraform apply -auto-approve

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your app URL: https://$(terraform output -raw container_app_url)" -ForegroundColor Cyan
```

Save this as `deploy.ps1` and run it after your initial `terraform apply`.

## Verification

Check that your image is in ACR:

```powershell
az acr repository list --name $ACR_NAME --output table
az acr repository show-tags --name $ACR_NAME --repository go-todo-app --output table
```

## Troubleshooting

### Authentication Issues
If you get authentication errors, try:
```powershell
az account show  # Verify you're logged into Azure
az acr login --name $ACR_NAME --expose-token  # Get token if needed
```

### Container App Not Starting
Check logs:
```powershell
$APP_NAME = terraform output -raw container_app_url
az containerapp logs show --name go-todo-app-dev --resource-group <your-rg> --follow
```

### Image Pull Errors
Verify the Container App has access to ACR:
- Check that admin access is enabled on ACR (done by Terraform)
- Verify credentials are correctly configured in Container App
