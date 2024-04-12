terraform {
  required_version = "~>1.6"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~>0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "prefix" {
  type    = string
  default = "elk"
}

variable "os_image" {
  type    = string
  default = "rhel-8.9-x86_64-kvm.qcow2"
}

resource "libvirt_network" "network" {
  name      = var.prefix
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
  autostart = true
  domain = "k8s.local"
  dhcp {
    enabled = true
  }
  dns {
    enabled    = true
    local_only = true
  }
}


resource "libvirt_volume" "volume" {
  name   = "${var.prefix}-${count.index}.img"
  source = var.os_image
  format = "qcow2"
  count  = 3
  #size             = 10 * 1024 * 1024 * 1024 # 10GiB. 
}


# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.1/website/docs/r/domain.html.markdown
resource "libvirt_domain" "domain" {
  name    = "${var.prefix}-${count.index}"
  machine = "q35"
  cpu {
    mode = "host-passthrough"
  }
  vcpu       = 2
  memory     = 2048
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.commoninit.id
  xml {
    xslt = file("libvirt-domain.xsl")
  }
  graphics {
    type = "vnc"
  }
  video {
    type = "vga"
  }
  disk {
    volume_id = element(libvirt_volume.volume.*.id, count.index)
    scsi      = true
  }
  network_interface {
    #network_name = "default"
    network_id     = libvirt_network.network.id
    hostname       = "${var.prefix}-${count.index}"
    wait_for_lease = true
  }
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  lifecycle {
    ignore_changes = [
      disk[0].wwn,
      disk[1].wwn,
    ]
  }
  count = 3
}


resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  pool      = "default"
  user_data = file("${path.module}/cloud_init.cfg")
}


output "ips" {
  value = libvirt_domain.domain.*.network_interface.0.addresses
}


# resource "time_sleep" "wait_for_ip" {
#   depends_on = [libvirt_domain.domain]
#   create_duration = "10s"
# }


# resource local_file "inventory" {
#   filename = "ansible-elk-inventory.ini"
#   content = templatefile("${path.module}/ansible-inventory.tpl",
#     {
#       elk1_ip = libvirt_domain.domain[0].network_interface.0.addresses[0],
#       elk2_ip = libvirt_domain.domain[1].network_interface.0.addresses[0],
#       server_user = "",
#       server_password = "",
#     })
#   depends_on = [ time_sleep.wait_for_ip ]
# }
