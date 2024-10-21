
resource "azurerm_container_registry" "acr" {
  name                = "testsparkakscontainerregistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "prod-k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "TestAKSCluster"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "testaksclusterprefix"
  kubernetes_version  = "1.29.9"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                        = "default"
    vm_size                     = "Standard_DS2_v2"
    node_count                  = 3
    vnet_subnet_id              = azurerm_subnet.infrastructure.id
  }

  linux_profile {
    admin_username = "azure"

    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  auto_scaler_profile {
    expander = "least-waste" # if not least waste
    #ignore-daemonsets-utilization = true
    scale_down_utilization_threshold = 0.2
    scale_down_unneeded              = "30m"
  }

  network_profile {
    network_plugin = "kubenet"
    service_cidr   = "10.1.0.0/16"      # Ensure this does not overlap with any subnets
    dns_service_ip = "10.1.0.10"        # Hardcoded DNS service IP
  }
}
