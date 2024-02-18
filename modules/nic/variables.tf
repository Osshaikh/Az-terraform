variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}


variable "subnet_id" {
  description = "The ID of the subnet where the network interface will be created"
  type        = string
}

variable "network_interface_name"{
    description = "The name of the network interface"
    default = "myNetworkInterface"
    }



variable "private_ip_address_allocation"{
    description = "The private ip address allocation method"
    default = "Dynamic"
    }

variable "dns_servers"{
    description = "The dns servers"
    default = ["8.8.8.8"]
}

variable "ip_configuration" {
  type = object({
    name                          = string
    private_ip_address_allocation = string
    dns_servers                   = list(string)
  })
}

variable "resource_group_name" {
  type = string
}

