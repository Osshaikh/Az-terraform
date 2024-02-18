locals {
  data_disk_list = flatten([
    for host_number in range(var.nb_instances) : [
      for data_disk_number in range(var.nb_data_disk) : {
        key         = join("-", ["datadisk", host_number, data_disk_number])
        name        = replace(replace(replace(var.name_template_data_disk, "$${vm_hostname}", var.vm_hostname), "$${host_number}", host_number), "$${data_disk_number}", data_disk_number)
        host_number = host_number
        disk_number = data_disk_number
      }
    ]
  ])
  data_disk_map         = { for obj in local.data_disk_list : obj.key => obj if !var.nested_data_disks }
  data_disk_map_linux   = { for obj in local.data_disk_list : obj.key => obj if !var.nested_data_disks && !local.is_windows }
  data_disk_map_windows = { for obj in local.data_disk_list : obj.key => obj if !var.nested_data_disks && local.is_windows }
  extra_disk_list = flatten([
    for host_number in range(var.nb_instances) : [
      for extra_disk in var.extra_disks : {
        key         = join("-", ["extradisk", host_number, extra_disk.name])
        name        = replace(replace(replace(var.name_template_extra_disk, "$${vm_hostname}", var.vm_hostname), "$${host_number}", host_number), "$${extra_disk_name}", extra_disk.name)
        host_number = host_number
        disk_number = index(var.extra_disks, extra_disk)
        disk_name   = extra_disk.name
        disk_size   = extra_disk.size
      }
    ]
  ])
  extra_disk_map              = { for obj in local.extra_disk_list : obj.key => obj if !var.nested_data_disks }
  extra_disk_map_linux        = { for obj in local.extra_disk_list : obj.key => obj if !var.nested_data_disks && !local.is_windows }
  extra_disk_map_windows      = { for obj in local.extra_disk_list : obj.key => obj if !var.nested_data_disks && local.is_windows }
  is_windows                  =  (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer")) || var.is_windows_image == true
  nested_data_disk_list       = var.nested_data_disks ? range(var.nb_data_disk) : []
  nested_extra_data_disk_list = var.nested_data_disks ? var.extra_disks : []
  vm_extensions               = { for p in setproduct(toset([for e in var.vm_extensions : e]), toset(range(var.nb_instances))) : "${p[0].name}-${p[1]}" => { index = p[1], value = p[0] } }
}



module "os" {
  source       = "./os"
  vm_os_simple = "${var.vm_os_simple}"
}

resource "azurerm_resource_group" "vm" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = "${var.vm_hostname}"
  }

  byte_length = 6
}

resource "azurerm_storage_account" "vm-sa" {
  count                    = "${var.boot_diagnostics == "true" ? 1 : 0}"
  name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
  resource_group_name      = "${azurerm_resource_group.vm.name}"
  location                 = "${var.location}"
  account_tier             = "${element(split("_", var.boot_diagnostics_sa_type),0)}"
  account_replication_type = "${element(split("_", var.boot_diagnostics_sa_type),1)}"
  tags                     = "${var.tags}"
}


resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_hostname}-avset"
  location                     = "${azurerm_resource_group.vm.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "vm" {
  count                        = "${var.nb_public_ip}"
  name                         = "${var.vm_hostname}-${count.index}-publicIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  allocation_method = "${var.public_ip_address_allocation}"
  domain_name_label            = "${element(var.public_ip_dns, count.index)}"
}

resource "azurerm_network_interface" "vm" {
  count                     = "${var.nb_instances}"
  name                      = "nic-${var.vm_hostname}-${count.index}"
  location                  = "${azurerm_resource_group.vm.location}"
  resource_group_name       = "${azurerm_resource_group.vm.name}"

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = "${var.vnet_subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, tolist([""])), count.index) : ""}"
  }
}

#resource "azurerm_network_interface_security_group_association" "nic-nsg"{
 # count = "${var.nb_instances}"
  #network_interface_id = "${element(azurerm_network_interface.vm.*.id, count.index)}"
  #network_security_group_id = "${azurerm_network_security_group.vm.id}"
#}

resource "azurerm_virtual_machine" "vm-linux" {
  count                         = "${!contains(tolist(["${var.vm_os_simple}","${var.vm_os_offer}"]), "WindowsServer") && var.is_windows_image != "true" && var.data_disk == "false" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}${count.index}"
  location                      = "${var.location}"
  resource_group_name           = "${azurerm_resource_group.vm.name}"
  availability_set_id           = "${azurerm_availability_set.vm.id}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "osdisk-${var.vm_hostname}-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}${count.index}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }

  tags = "${var.tags}"

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }
}

resource "azurerm_virtual_machine" "vm-linux-with-datadisk" {
  count                         = "${!contains(tolist(["${var.vm_os_simple}","${var.vm_os_offer}"]), "WindowsServer")  && var.is_windows_image != "true"  && var.data_disk == "true" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}${count.index}"
  location                      = "${var.location}"
  resource_group_name           = "${azurerm_resource_group.vm.name}"
  availability_set_id           = "${azurerm_availability_set.vm.id}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "osdisk-${var.vm_hostname}-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
    #disk_size_gb      = "${var.os_disk_size_gb}"
  }

  storage_data_disk {
    name              = "datadisk-${var.vm_hostname}-${count.index}"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "${var.data_disk_size_gb}"
    managed_disk_type = "${var.data_sa_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}${count.index}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }

  tags = "${var.tags}"

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }
}