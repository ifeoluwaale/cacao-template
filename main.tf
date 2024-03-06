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
    flavor_name = var.flavor_name
    key_pair = var.key_pair
    security_groups = ["cacao-default"]
    power_state = var.power_state
    user_data = var.user_data

    network {
        name = "auto_allocated_network"
    }

    block_device {
        uuid = local.image_uuid
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
    }

    ignore_changes = [
        image_id, name, user_data
    ]
}

data "openstack_images_image_v2" "instance_image" {
  count = var.image_name == "" ? 0 : 1
  name = var.image_name
  most_recent = true
}


locals {
  image_id = var.image_name == "" ? var.image : data.openstack_images_image_v2.instance_image.0.id
}
