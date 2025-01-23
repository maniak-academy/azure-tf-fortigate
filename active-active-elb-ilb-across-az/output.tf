output "ResourceGroup" {
  value = azurerm_resource_group.myterraformgroup.name
}

# output "ClusterPublicIP" {
#   value = azurerm_public_ip.ClusterPublicIP.ip_address
# }

output "MGMTPublicIPA" {
  value = format("https://%s:%s", azurerm_public_ip.ActiveMGMTIP.ip_address, var.adminsport)
}

output "MGMTPublicIPB" {
  value = format("https://%s:%s", azurerm_public_ip.PassiveMGMTIP.ip_address, var.adminsport)
}

output "Username" {
  value = var.adminusername
}

output "Password" {
  value = var.adminpassword
}

