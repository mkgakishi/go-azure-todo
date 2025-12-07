variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-go-todo-app"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "South Africa North"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "go-todo"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "go-todo-app"
    ManagedBy   = "Terraform"
  }
}

# MongoDB/Cosmos DB Variables
variable "mongodb_database_name" {
  description = "Name of the MongoDB database"
  type        = string
  default     = "tododb"
}

# Redis Cache Variables
variable "redis_capacity" {
  description = "Redis cache capacity"
  type        = number
  default     = 0
}

variable "redis_family" {
  description = "Redis cache family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "Redis cache SKU name (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

# Container App Variables
variable "docker_image_name" {
  description = "Name of the Docker image (without registry or tag)"
  type        = string
  default     = "go-todo-app"
}

variable "docker_image_tag" {
  description = "Tag for the Docker image"
  type        = string
  default     = "latest"
}

variable "container_cpu" {
  description = "CPU allocation for container (e.g., 0.25, 0.5, 1.0)"
  type        = number
  default     = 0.5
}

variable "container_memory" {
  description = "Memory allocation for container (e.g., 0.5Gi, 1Gi)"
  type        = string
  default     = "1Gi"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 3
}

variable "ingress_external_enabled" {
  description = "Whether to enable external ingress (true for public, false for internal only)"
  type        = bool
  default     = true
}

variable "internal_load_balancer_enabled" {
  description = "Whether to use internal load balancer for Container Apps Environment"
  type        = bool
  default     = false
}
