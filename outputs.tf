output "ansible_inventory_path" {
  description = "Path to the host yaml file"
  value = var.do_ansible_execution && var.power_state == "active" ? abspath(local_file.ansible-inventory[0].filename) : ""
}

output "ansible_execution_completed" {
  description = "Indicates if the ansible execution was completed"
  value = var.do_ansible_execution && var.power_state == "active" ? local_file.ansible-inventory[0].id : ""
}
