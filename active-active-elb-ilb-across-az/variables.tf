// Azure configuration
variable "subscription_id" {

}
variable "client_id" {

}
variable "client_secret" {

}
variable "tenant_id" {

}


//  For HA, choose instance size that support 4 nics at least
//  Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
// x86 - Standard_F8s_v2
// arm - Standard_D2ps_v5
variable "size" {
  type    = string
  default = "Standard_F4s"
}

// Resource Group Name
variable "resourcegroupname" {
  type    = string
  default = "fortigate-rg"
}
// Firewall Name
variable "firewallname1" {
  type    = string
  default = "fgt-fw1" 
}

// Firewall Name
variable "firewallname2" {
  type    = string
  default = "fgt-fw2" 
}

// Availability zones only support in certain regions
// Check: https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
variable "zone1" {
  type    = string
  default = "1"
}

variable "zone2" {
  type    = string
  default = "2"
}

variable "location" {
  type    = string
  default = "canadacentral"
}

// To use custom image 
// by default is false
variable "custom" {
  default = false
}

//  Custom image blob uri
variable "customuri" {
  type    = string
  default = "<custom image blob uri>"
}

variable "custom_image_name" {
  type    = string
  default = "<custom image name>"
}

variable "custom_image_resource_group_name" {
  type    = string
  default = "<custom image resource group>"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "payg"
}

// instance architect
// Either arm or x86
variable "arch" {
  default = "x86"
}

// To accept marketplace agreement
// Default is false
variable "accept" {
  default = "false"
}

// BYOL License format to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either token or file.
variable "license_format" {
  default = "file"
}

variable "publisher" {
  type    = string
  default = "fortinet"
}

variable "fgtoffer" {
  type    = string
  default = "fortinet_fortigate-vm_v5"
}

// x86
// BYOL sku: fortinet_fg-vm_g2
// PAYG sku: fortinet_fg-vm_payg_2023_g2
// arm
// BYOL sku: fortinet_fg-vm_arm64
// PAYG sku: fortinet_fg-vm_payg_2023_arm64
variable "fgtsku" {
  type = map(any)
  default = {
    x86 = {
      byol = "fortinet_fg-vm_g2"
      payg = "fortinet_fg-vm_payg_2023_g2"
    },
    arm = {
      byol = "fortinet_fg-vm_arm64"
      payg = "fortinet_fg-vm_payg_2023_arm64"
    }
  }
}

// FOS version
variable "fgtversion" {
  type    = string
  default = "7.6.1"
}

variable "adminusername" {
  type    = string
  default = "azureadmin"
}

variable "adminpassword" {
  type    = string
  default = "Fortinet123#"
}

// HTTPS Port
variable "adminsport" {
  type    = string
  default = "8443"
}

variable "vnetcidr" {
  default = "172.1.0.0/16"
}

variable "publiccidr" {
  default = "172.1.0.0/24"
}

variable "privatecidr" {
  default = "172.1.1.0/24"
}

variable "hasynccidr" {
  default = "172.1.2.0/24"
}

variable "hamgmtcidr" {
  default = "172.1.3.0/24"
}

variable "deviceaport1" {
  default = "172.1.3.10"
}

variable "deviceaport1mask" {
  default = "255.255.255.0"
}

variable "deviceaport2" {
  default = "172.1.0.10"
}

variable "deviceaport2mask" {
  default = "255.255.255.0"
}

variable "deviceaport3" {
  default = "172.1.1.10"
}

variable "deviceaport3mask" {
  default = "255.255.255.0"
}

# variable "deviceaport4" {
#   default = "172.1.2.10"
# }

# variable "deviceaport4mask" {
#   default = "255.255.255.0"
# }

variable "devicebport1" {
  default = "172.1.3.11"
}

variable "devicebport1mask" {
  default = "255.255.255.0"
}

variable "devicebport2" {
  default = "172.1.0.11"
}

variable "devicebport2mask" {
  default = "255.255.255.0"
}

variable "devicebport3" {
  default = "172.1.1.11"
}

variable "devicebport3mask" {
  default = "255.255.255.0"
}

# variable "devicebport4" {
#   default = "172.1.2.11"
# }

# variable "devicebport4mask" {
#   default = "255.255.255.0"
# }

variable "port1gateway" {
  default = "172.1.3.1"
}

variable "port2gateway" {
  default = "172.1.0.1"
}
variable "port3gateway" {
  default = "172.1.1.1"
}
variable "ilb-ip" {
  default = "172.1.1.13"
}

variable "bootstrap-devicea" {
  // Change to your own path
  type    = string
  default = "config-fwA.conf"
}

variable "bootstrap-deviceb" {
  // Change to your own path
  type    = string
  default = "config-fwB.conf"
}


// license file for the devicea fgt
variable "license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "license.txt"
}

// license file for the deviceb fgt
variable "license2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "license2.txt"
}

variable "common_tags" {
  type        = map(string)
  description = <<EOT
Map of common tags to be applied to all resources.
Include fields like owner, description, contact, environment, zone, etc.
EOT

  default = {
    owner       = "Sebatian Maniak"
    description = "Terraform-managed FortiGate HA Setup"
    contact     = "sebatian@maniak.io"
    environment = "development"
    zone        = "canadacentral"
  }
}
