resource "azurerm_lb" "internal_lb" {
  name                = "internal-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internalFrontend"
    subnet_id                     = azurerm_subnet.privatesubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ilb-ip
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}
resource "azurerm_lb_backend_address_pool" "internal_lb_backend" {
  name            = "int-lb-backendpool"
  loadbalancer_id = azurerm_lb.internal_lb.id
}
resource "azurerm_lb_probe" "int_lb_probe" {
  name            = "int-lb-probe"
  loadbalancer_id = azurerm_lb.internal_lb.id

  protocol = "Tcp"
  port     = 8008
}

resource "azurerm_lb_rule" "int_lb_rule" {
  name            = "int-lb-rule"
  loadbalancer_id = azurerm_lb.internal_lb.id

  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "internalFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal_lb_backend.id]
  probe_id                       = azurerm_lb_probe.int_lb_probe.id

  enable_floating_ip      = true
  idle_timeout_in_minutes = 5
  load_distribution       = "Default"
}
resource "azurerm_network_interface_backend_address_pool_association" "activeport3_intlb" {
  network_interface_id    = azurerm_network_interface.activeport3.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_backend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "passiveport3_intlb" {
  network_interface_id    = azurerm_network_interface.passiveport3.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_lb_backend.id
}
