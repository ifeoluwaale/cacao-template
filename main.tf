terraform {
    required_providers {
      openstack = {
        source = "terraform-provider-openstack/openstack"
      }
    }
}

provider "openstack" {
    tenant_name = var.project
    region = var.region
}

resource "openstack_compute_instance_v2" "os_instances" {
    name = var.instance_count == 1 ? var.instance_name : "${var.instance_name}${count.index}"
    count = var.instance_count
    image_id = local.image_id
    flavor_name = var.flavor
    key_pair = var.keypair
    security_groups = ["cacao-default"]
    power_state = var.power_state
    user_data = var.user_data

    network {
        name = "auto_allocated_network"
    }

    block_device {
        uuid = local.image_id
        source_type = var.root_storage_source
        destination_type = var.root_storage_type
        boot_index = 0
        delete_on_termination = var.root_storage_delete_on_termination
        volume_size = local.volume_size
    }

    lifecycle {
        precondition {
            condition = var.image != "" || var.image_name != ""
            error_message = "ERROR: template input image or image_name must be set"
        }
      ignore_changes = [
        image_id, name, user_data
      ]
    }
}

data "openstack_networking_network_v2" "ext_network" {
  region = var.region
  external = true
}


resource "openstack_networking_floatingip_v2" "os_floatingips" {
  count = var.power_state == "active" ? var.instance_count : 0
  pool = data.openstack_networking_network_v2.ext_network.name
  description = "floating ip for ${var.instance_name}, ${count.index}/${var.instance_count}"
}

resource "time_sleep" "fip_associate_timewait" {
  count = var.power_state == "active" ? 1 : 0
  depends_on = [openstack_compute_instance_v2.os_instances[0], openstack_networking_floatingip_v2.os_floatingips[0]]
  create_duration = var.fip_associate_timewait
}

resource "openstack_compute_floatingip_associate_v2" "os_floatingips_associate" {
  count = var.power_state == "active" ? var.instance_count : 0
  floating_ip = openstack_networking_floatingip_v2.os_floatingips[count.index].address
  instance_id = openstack_compute_instance_v2.os_instances[count.index].id
  depends_on = [time_sleep.fip_associate_timewait[0]]
}


data "openstack_images_image_v2" "instance_image" {
  count = var.image_name == "" ? 0 : 1
  name = var.image_name
  most_recent = true
}


locals {
  image_id = var.image_name == "" ? var.image : data.openstack_images_image_v2.instance_image.0.id
  volume_size = var.root_storage_size > 0 ? var.root_storage_size : null
}
