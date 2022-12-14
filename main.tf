terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

variable "vsphere_user" {
  type = string
  default = ""
}

variable "vsphere_password" {
  type = string
  default = ""
  sensitive = true
}

variable "vsphere_server" {
  type = string
  default = ""
}

variable "vm_name" {
  type = string
  default = ""
}

variable "num_cpus" {
  type = number
  default = 1  
}

variable "memory" {
  type = number
  default = 1024  
}

variable "disk_size" {
  type = number
  default = 20 
}

variable "vm_count" {
  type = number
  default = 0
}

data "vsphere_datacenter" "datacenter" {
  name = "DC0"
}

data "vsphere_datastore" "datastore" {
  name = "LocalDS_0"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = "DC0_C0"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = "/DC0/host/DC0_H0/Resources"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  count            = var.vm_count
  name             = "BoA-Demo-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.num_cpus
  memory           = var.memory
  guest_id         = "other3xLinux64Guest"
 
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  
  disk {
    label = "disk0"
    size  = var.disk_size
  }
  wait_for_guest_net_routable = false
  wait_for_guest_ip_timeout = 0
  wait_for_guest_net_timeout = 0
}