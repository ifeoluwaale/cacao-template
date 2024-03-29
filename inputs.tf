variable "username" {
  type = string
  description = "username"
}

variable "project" {
  type = string
  description = "project name"
}

variable "region" {
  type = string
  description = "string, openstack region name; default = IU"
  default = "IU"
}

variable "instance_name" {
  type = string
  description = "name of instance"
}

variable "instance_count" {
  type = number
  description = "number of instances to launch"
  default = 1
}

variable "image" {
  type = string
  description = "string, image id; image will have priority if both image and image name are provided"
  default = ""
}

variable "image_name" {
  type = string
  description = "string, name of image; image will have priority if both image and image name are provided"
  default = ""
}

variable "flavor" {
  type = string
  description = "flavor or size of instance to launch"
  default = "m3.tiny"
}

variable "keypair" {
  type = string
  description = "keypair to use when launching"
  default = ""
}

variable "power_state" {
  type = string
  description = "power state of instance"
  default = "active"
}

variable "ip_pool" {
  type = string
  description = "deprecated"
  default = "public"
}

variable "user_data" {
  type = string
  description = "cloud init script"
  default = ""
}

variable "do_ansible_execution" {
  type = bool
  description = "boolean, whether to execute ansible"
  default = true
}

variable "root_storage_source" {
  type = string
  description = "string, source currently supported is image; future values will include volume, snapshot, blank"
  default = "image"
}

variable "root_storage_type" {
  type = string
  description = "string, type is either local or volume"
  default = "local"
}

variable "root_storage_size" {
  type = number
  description = "number, size in GB"
  default = -1
}

variable "root_storage_delete_on_termination" {
  type = bool
  description = "bool, if true delete on termination"
  default = true
}

variable "fip_associate_timewait" {
  type = string
  description = "number, time to wait before associating a floating ip in seconds; needed for jetstream; will not be exposed to downstream clients"
  default = "30s"
}
