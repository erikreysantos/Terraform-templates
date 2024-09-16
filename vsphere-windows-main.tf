provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true  # Optional, depending on your SSL setup
}

# Data source for vSphere datacenter
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

# Data source for vSphere cluster
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source for vSphere datastore
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source for vSphere network
data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source for the template
data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
  folder = "Templates"
}

# Create a virtual machine
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "Test"  # Adjust if you want to store the VM in a specific folder
  firmware = "efi"

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"

  }

  disk {
    label            = "disk0"
    #name            = "[SOLN-NX8155N-G8-PRIMARY-CONTAINER] test_1/test.vmx"
    size             = 150
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name  = var.vm_name
        admin_password = var.admin_password
        time_zone      = 215  # Singapore Standard Time (UTC+8:00)
        #join_domain = var.domain_name
        #domain_admin_user = var.domain_name
        #domain_admin_password = var.domain_password
      }

      network_interface {
        ipv4_address = var.vm_ip
        ipv4_netmask = 24
        dns_server_list  = var.dns_servers
      }

      ipv4_gateway = var.vm_gateway   
    }
  }
    
}
