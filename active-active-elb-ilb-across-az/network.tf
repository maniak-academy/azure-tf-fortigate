// Create Virtual Network

resource "azurerm_virtual_network" "fgtvnetwork" {
  name                = "fgtvnetwork"
  address_space       = [var.vnetcidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_subnet" "publicsubnet" {
  name                 = "publicSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.publiccidr]
}

resource "azurerm_subnet" "privatesubnet" {
  name                 = "privateSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.privatecidr]
}

resource "azurerm_subnet" "hasyncsubnet" {
  name                 = "HASyncSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.hasynccidr]
}

resource "azurerm_subnet" "hamgmtsubnet" {
  name                 = "HAMGMTSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.hamgmtcidr]
}


// Allocated Public IP
# resource "azurerm_public_ip" "ClusterPublicIP" {
#   name                = "ClusterPublicIP"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.myterraformgroup.name
#   sku                 = "Standard"
#   allocation_method   = "Static"
#   zones               = [var.zone1, var.zone2]

#   tags = {
#     environment = "Terraform HA AP SDN FortiGates - Crosszone"
#   }
# }

resource "azurerm_public_ip" "deviceaMGMTIP" {
  name                = "deviceaMGMTIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_public_ip" "devicebMGMTIP" {
  name                = "devicebMGMTIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

//  Network Security Group
resource "azurerm_network_security_group" "publicnetworknsg" {
  name                = "PublicNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "TCP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_security_group" "privatenetworknsg" {
  name                = "PrivateNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "All"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_security_rule" "outgoing_public" {
  name                        = "egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.publicnetworknsg.name
}

resource "azurerm_network_security_rule" "outgoing_private" {
  name                        = "egress-private"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.privatenetworknsg.name
}


// devicea FGT Network Interface port1
resource "azurerm_network_interface" "deviceaport1" {
  name                = "deviceaport1"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hamgmtsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.deviceaport1
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.deviceaMGMTIP.id
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_interface" "deviceaport2" {
  name                  = "deviceaport2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.publicsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.deviceaport2
    #public_ip_address_id          = null
    #public_ip_address_id          = azurerm_public_ip.ClusterPublicIP.id

  }


  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_interface" "deviceaport3" {
  name                  = "deviceaport3"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.privatesubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.deviceaport3
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_interface" "deviceaport4" {
  name                = "deviceaport4"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hasyncsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.deviceaport4
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "port1nsg" {
  depends_on                = [azurerm_network_interface.deviceaport1]
  network_interface_id      = azurerm_network_interface.deviceaport1.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "port4nsg" {
  depends_on                = [azurerm_network_interface.deviceaport4]
  network_interface_id      = azurerm_network_interface.deviceaport4.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "port2nsg" {
  depends_on                = [azurerm_network_interface.deviceaport2]
  network_interface_id      = azurerm_network_interface.deviceaport2.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "port3nsg" {
  depends_on                = [azurerm_network_interface.deviceaport3]
  network_interface_id      = azurerm_network_interface.deviceaport3.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}

// deviceb FGT Network Interface port1
resource "azurerm_network_interface" "devicebport1" {
  name                = "devicebport1"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hamgmtsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.devicebport1
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.devicebMGMTIP.id
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_interface" "devicebport2" {
  name                  = "devicebport2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.publicsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.devicebport2
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_interface" "devicebport3" {
  name                  = "devicebport3"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.privatesubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.devicebport3
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_network_interface" "devicebport4" {
  name                = "devicebport4"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hasyncsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.devicebport4
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}


# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "devicebport1nsg" {
  depends_on                = [azurerm_network_interface.devicebport1]
  network_interface_id      = azurerm_network_interface.devicebport1.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "devicebport4nsg" {
  depends_on                = [azurerm_network_interface.devicebport4]
  network_interface_id      = azurerm_network_interface.devicebport4.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "devicebport2nsg" {
  depends_on                = [azurerm_network_interface.devicebport2]
  network_interface_id      = azurerm_network_interface.devicebport2.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "devicebport3nsg" {
  depends_on                = [azurerm_network_interface.devicebport3]
  network_interface_id      = azurerm_network_interface.devicebport3.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}
