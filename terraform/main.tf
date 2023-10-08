# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location

  tags = {
    Project = "AzureDevOps"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Project = "AzureDevOps"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Project = "AzureDevOps"
  }
}

resource "azurerm_network_security_rule" "deny_internet" {
  name                        = "deny-internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "internal_inbound" {
  name                        = "internal-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "internal_outbound" {
  name                        = "internal-outbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "internal_inbound_lb_vm" {
  count                       = 2
  name                        = "internal-inbound-lb-vm-${count.index}"
  priority                    = 200 + (count.index + 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = azurerm_network_interface.main[count.index].private_ip_address
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface" "main" {
  count               = 2
  name                = "${var.prefix}-nic-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Project = "AzureDevOps"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku = "Standard"

  tags = {
    Project = "AzureDevOps"
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku = "Standard"
  frontend_ip_configuration {
    name                 = "${var.prefix}-lb-frontend"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    Project = "AzureDevOps"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  name                = "${var.prefix}-backend-pool"
  loadbalancer_id     = azurerm_lb.main.id
}

resource "azurerm_lb_probe" "main" {
  name                = "${var.prefix}-tcp-probe"
  protocol            = "Tcp"
  port                = 80
  loadbalancer_id     = azurerm_lb.main.id
}

resource "azurerm_lb_rule" "main" {
  name                           = "${var.prefix}-alb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
  loadbalancer_id                = azurerm_lb.main.id
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = 2
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name  = azurerm_network_interface.main[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-availability-set"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  platform_fault_domain_count = "${var.platform_fault_domain_count}"
  platform_update_domain_count = "${var.platform_update_domain_count}"

  tags = {
    Project = "AzureDevOps"
  }
}

data "azurerm_image" "main" {
  name                = var.packer_image_name
  resource_group_name = var.packer_image_resource_group
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = 2
  name                            = "${var.prefix}-vm-${count.index + 1}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  availability_set_id             = azurerm_availability_set.main.id
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  source_image_id = data.azurerm_image.main.id

  os_disk {
	  name = "${var.prefix}-os-disk-${count.index + 1}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    Project = "AzureDevOps"
  }
}