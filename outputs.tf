output "vm_public_ip" {
  value = azurerm_public_ip.jumphost_ip.ip_address
  description = "The public IP of the jump host VM"
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
  description = "The name of the resource group"
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.prod-k8s.name
  description = "The name of the AKS cluster"
}

output "storage_account_name" {
  value       = azurerm_storage_account.storageaccount.name
  description = "The name of the Azure Storage account"
}

output "storage_container_name" {
  value       = azurerm_storage_container.storagecontainer.name
  description = "The name of the Azure Storage container"
}

output "storage_account_key" {
  value       = azurerm_storage_account.storageaccount.primary_access_key
  description = "The primary access key of the Azure Storage account"
  sensitive   = true
}