variable "vsphere_user" {
  description = "The vSphere user to connect with."
}

variable "vsphere_password" {
  description = "The vSphere password to connect with."
  sensitive   = true
}

variable "vsphere_server" {
  description = "The vSphere server hostname or IP."
}

variable "datacenter" {
  description = "The vSphere datacenter to deploy the VM in."
}

variable "cluster" {
  description = "The vSphere cluster to deploy the VM in."
}

variable "datastore" {
  description = "The vSphere datastore to deploy the VM in."
}

variable "network" {
  description = "The vSphere network to connect the VM to."
}

variable "template_name" {
  description = "The name of the Windows Server template in vSphere."
}

variable "vm_name" {
  description = "The name of the Windows Server VM."
}

variable "admin_password" {
  description = "The admin password for the Windows Server."
  sensitive   = true
}

variable "vm_ip" {
  description = "The static IP address for the Windows Server."
}

variable "vm_gateway" {
  description = "The gateway for the Windows Server."
}

variable "dns_servers" {
  description = "List of DNS servers for the Windows Server."
  type        = list(string)
}

# Domain join variables
variable "domain_name" {
  description = "The Active Directory domain to join the Windows Server to."
}

variable "domain_user" {
  description = "The domain user for domain join (use 'DOMAIN\\username' format)."
}

variable "domain_password" {
  description = "The domain password for the domain user."
  sensitive   = true
}



