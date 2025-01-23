resource "azurerm_public_ip" "external_lb_public_ip" {
  name                = "external-lb-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"
  # Optionally set zones if you have zone redundancy:
  zones             = [var.zone1, var.zone2]

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_lb" "external_lb" {
  name                = "external-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "externalFrontend"
    public_ip_address_id = azurerm_public_ip.external_lb_public_ip.id
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}

resource "azurerm_lb_backend_address_pool" "external_lb_backend" {
  name            = "ext-lb-backendpool"
  loadbalancer_id = azurerm_lb.external_lb.id
}

resource "azurerm_lb_probe" "ext_lb_probe" {
  name            = "ext-lb-probe"
  loadbalancer_id = azurerm_lb.external_lb.id

  protocol = "Tcp"
  port     = 8008
  # Adjust for your FGT actual service or dedicated health-check port
}

resource "azurerm_lb_rule" "ext_lb_rule_tcp" {
  name            = "ext-lb-rule-tcp"
  loadbalancer_id = azurerm_lb.external_lb.id

  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "externalFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.external_lb_backend.id]
  probe_id                       = azurerm_lb_probe.ext_lb_probe.id

  enable_floating_ip = true
}

resource "azurerm_lb_rule" "ext_lb_rule_udp" {
  name            = "ext-lb-rule-udp"
  loadbalancer_id = azurerm_lb.external_lb.id

  protocol                       = "Udp"
  frontend_port                  = 10551
  backend_port                   = 10551
  frontend_ip_configuration_name = "externalFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.external_lb_backend.id]
  probe_id                       = azurerm_lb_probe.ext_lb_probe.id

  enable_floating_ip = true
}


resource "azurerm_network_interface_backend_address_pool_association" "activeport2_extlb" {
  network_interface_id    = azurerm_network_interface.activeport2.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.external_lb_backend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "passiveport2_extlb" {
  network_interface_id    = azurerm_network_interface.passiveport2.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.external_lb_backend.id
}
