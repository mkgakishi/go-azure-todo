# Get Terraform outputs
$ACR_LOGIN_SERVER = terraform output -raw container_registry_login_server
$ACR_NAME = $ACR_LOGIN_SERVER -replace '\.azurecr\.io',''
$IMAGE_NAME = "go-todo-app"
$IMAGE_TAG = "latest"

Write-Host "`n=== Building and Deploying Go Todo App ===" -ForegroundColor Cyan

# Step 1: Login to ACR
Write-Host "`n[1/4] Logging into Azure Container Registry..." -ForegroundColor Green
az acr login --name $ACR_NAME

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to login to ACR. Make sure you're logged into Azure (az login)" -ForegroundColor Red
    exit 1
}

# Step 2: Build Docker image
Write-Host "`n[2/4] Building Docker image..." -ForegroundColor Green
docker build -t ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to build Docker image" -ForegroundColor Red
    exit 1
}

# Step 3: Push to ACR
Write-Host "`n[3/4] Pushing image to Azure Container Registry..." -ForegroundColor Green
docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to push image to ACR" -ForegroundColor Red
    exit 1
}

# Step 4: Update Container App
Write-Host "`n[4/4] Updating Container App..." -ForegroundColor Green
terraform apply -auto-approve

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to update Container App" -ForegroundColor Red
    exit 1
}

# Success
Write-Host "`n=== Deployment Complete! ===" -ForegroundColor Cyan
$APP_URL = terraform output -raw container_app_url
Write-Host "Your app is available at: https://$APP_URL" -ForegroundColor Green
Write-Host "`nTo view logs, run:" -ForegroundColor Yellow
Write-Host "  az containerapp logs show --name go-todo-app-dev --resource-group <your-rg> --follow" -ForegroundColor Gray
