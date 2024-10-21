resource "local_file" "local_script" {
  filename = "${path.module}/setup_bastion.sh"
  content  = file("${path.module}/setup_bastion.sh")
}


resource "azurerm_public_ip" "jumphost_ip" {
  name                = "testaks-jumphost-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"  # Ensure you use Standard SKU if you have a Standard NAT Gateway
}

resource "azurerm_network_interface" "jumphost_nic" {
  name                = "testaks-jumphost-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testaks-jumphost-nic-config"
    subnet_id                     = azurerm_subnet.infrastructure.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumphost_ip.id
  }
}


resource "azurerm_linux_virtual_machine" "jumphost_vm" {
  name                  = "testaks-jumphost"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jumphost_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "JumphostOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username                  = var.vm_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_username
    public_key = file("~/.ssh/id_rsa.pub")  
  }
}

resource "azurerm_virtual_machine_extension" "jumphost_setup_script" {
  name                 = "jumphost-setup"
  virtual_machine_id   = azurerm_linux_virtual_machine.jumphost_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  # Step 4: Run the local setup.sh script
  settings = jsonencode({
      "commandToExecute": "bash -c '${local_file.local_script.content}'"
    })
}