provider "vsphere" {
  user           = "administrator@norcal.local"
  password       = "Password1!"
  vsphere_server = "10.237.33.9"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "NorCal"
}

data "vsphere_datastore" "datastore" {
  name          = "vnx2-ds1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
 name           = "Dell" 
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "dPG Corp VLAN 32"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
 name           = "1 Templates/template-ubuntu1604"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "vjustin"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 2
  memory   = 1024
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label = "disk0"
    size  = 80
  }
  clone {
   template_uuid = "${data.vsphere_virtual_machine.template.id}"
   
   customize {
    linux_options {
     host_name = "vjustin"
     domain = ".local"
     }
     
    network_interface {
     ipv4_address="10.237.32.96"
     ipv4_netmask=24
    }
    
    ipv4_gateway = "10.237.32.1"
    dns_server_list = ["10.237.33.254"]
     }
    }
   
   provisioner "file" {
    source = "setup.sh"
    destination = "/tmp/setup.sh"
    
    connection {
     type = "ssh"
     user = "administrator"
     password = "password"
    }
   }
   
   provisioner "remote-exec" {
    inline = [
    "echo password|sudo -S chmod +x /tmp/setup.sh",
    "echo password|sudo -S /tmp/setup.sh",
   ]
   
   connection {
    type = "ssh"
    user = "administrator"
    password = "password"
   }
  }
}
