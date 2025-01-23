# resource "azurerm_virtual_machine" "customfgtvmB" {
#   depends_on                   = [azurerm_virtual_machine.customfgtvmA]
#   count                        = var.custom ? 1 : 0
#   name                         = "customdevicebfgt"
#   location                     = var.location
#   resource_group_name          = azurerm_resource_group.myterraformgroup.name
#   network_interface_ids        = [azurerm_network_interface.devicebport1.id, azurerm_network_interface.devicebport2.id, azurerm_network_interface.devicebport3.id, azurerm_network_interface.devicebport4.id]
#   primary_network_interface_id = azurerm_network_interface.devicebport1.id
#   vm_size                      = var.size
#   zones                        = [var.zone2]

#   delete_os_disk_on_termination    = true
#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     id = var.custom ? element(azurerm_image.custom.*.id, 0) : null
#   }

#   storage_os_disk {
#     name              = "devicebosDisk"
#     caching           = "ReadWrite"
#     managed_disk_type = "Standard_LRS"
#     create_option     = "FromImage"
#   }

#   # Log data disks
#   storage_data_disk {
#     name              = "devicebdatadisk"
#     managed_disk_type = "Standard_LRS"
#     create_option     = "Empty"
#     lun               = 0
#     disk_size_gb      = "30"
#   }

#   os_profile {
#     computer_name  = "customdevicebfgt"
#     admin_username = var.adminusername
#     admin_password = var.adminpassword
#     custom_data = templatefile("${var.bootstrap-deviceb}", {
#       type            = var.license_type
#       license_file    = var.license2
#       format          = "${var.license_format}"
#       port1_ip        = var.devicebport1
#       port1_mask      = var.devicebport1mask
#       port2_ip        = var.devicebport2
#       port2_mask      = var.devicebport2mask
#       port3_ip        = var.devicebport3
#       port3_mask      = var.devicebport3mask
#       port4_ip        = var.devicebport4
#       port4_mask      = var.devicebport4mask
#       devicea_peerip   = var.deviceaport4
#       mgmt_gateway_ip = var.port1gateway
#       defaultgwy      = var.port2gateway
#       tenant          = var.tenant_id
#       subscription    = var.subscription_id
#       clientid        = var.client_id
#       clientsecret    = var.client_secret
#       adminsport      = var.adminsport
#       rsg             = azurerm_resource_group.myterraformgroup.name
#       #clusterip       = azurerm_public_ip.ClusterPublicIP.name
#       ilb-ip          = var.ilb-ip
#       routename = azurerm_route_table.internal.name
#     })
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   boot_diagnostics {
#     enabled     = true
#     storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
#   }

#   tags = {
#     environment = "Terraform HA AP SDN FortiGates - Crosszone"
#   }
# }


resource "azurerm_virtual_machine" "fgtvmB" {
  depends_on                   = [azurerm_virtual_machine.fgtvmA]
  count                        = var.custom ? 0 : 1
  name                         = var.firewallname2
  location                     = var.location
  resource_group_name          = azurerm_resource_group.myterraformgroup.name
  network_interface_ids        = [azurerm_network_interface.devicebport1.id, azurerm_network_interface.devicebport2.id, azurerm_network_interface.devicebport3.id, azurerm_network_interface.devicebport4.id]
  primary_network_interface_id = azurerm_network_interface.devicebport1.id
  vm_size                      = var.size
  zones                        = [var.zone2]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.custom ? null : var.publisher
    offer     = var.custom ? null : var.fgtoffer
    sku       = var.fgtsku[var.arch][var.license_type]
    version   = var.custom ? null : var.fgtversion
    id        = var.custom ? element(azurerm_image.custom.*.id, 0) : null
  }

  plan {
    name      = var.fgtsku[var.arch][var.license_type]
    publisher = var.publisher
    product   = var.fgtoffer
  }

  storage_os_disk {
    name              = "devicebosDisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "devicebdatadisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "devicebfgt"
    admin_username = var.adminusername
    admin_password = var.adminpassword
    custom_data = templatefile("${var.bootstrap-deviceb}", {
      type            = var.license_type
      license_file    = var.license2
      format          = "${var.license_format}"
      firewallname2 = var.firewallname2
      port1_ip        = var.devicebport1
      port1_mask      = var.devicebport1mask
      port2_ip        = var.devicebport2
      port2_mask      = var.devicebport2mask
      port3_ip        = var.devicebport3
      port3_mask      = var.devicebport3mask
      port4_ip        = var.devicebport4
      port4_mask      = var.devicebport4mask
      devicea_peerip   = var.deviceaport4
      mgmt_gateway_ip = var.port1gateway
      defaultgwy      = var.port2gateway
      tenant          = var.tenant_id
      subscription    = var.subscription_id
      clientid        = var.client_id
      clientsecret    = var.client_secret
      adminsport      = var.adminsport
      port2gateway    = var.port2gateway
      port3gateway    = var.port3gateway
      rsg             = azurerm_resource_group.myterraformgroup.name
      #clusterip       = azurerm_public_ip.ClusterPublicIP.name
      ilb-ip    = var.ilb-ip
      routename = azurerm_route_table.internal.name
    })
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.fgtstorageaccount.primary_blob_endpoint
  }

  tags = merge(
    var.common_tags,
    {
      "additional_tag_key" = "additional_tag_value"
    }
  )
}
