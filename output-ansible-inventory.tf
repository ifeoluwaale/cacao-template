resource "local_file" "ansible-inventory" {
    count = var.power_state == "active" ? 1 : 0
    content = templatefile("${path.module}/hosts.yml.tmpl",
    {
        server_ips = openstack_compute_floatingip_associate_v2.os_floatingips_associate.*.floating_ip
        server_names = openstack_compute_instance_v2.os_instances.*.name # we could use this instead of an generically generated index name
        cacao_user = var.username
    })
    filename = "${path.module}/ansible/hosts.yml"
}

resource "null_resource" "ansible-execution" {
    count = var.do_ansible_execution && var.power_state == "active" ? 1 : 0

    triggers = {
        always_run = "${timestamp()}"
    }

    # this is temporary
    # provisioner "local-exec" {
    #     command = "apt-get update && apt-get install -y git"
    #     working_dir = "${path.module}/ansible"
    # }

    provisioner "local-exec" {
        command = "ansible-galaxy install -r requirements.yaml -f"
        working_dir = "${path.module}/ansible"
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_PIPELINING=True ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i hosts.yml --forks=10 playbook.yaml"
        working_dir = "${path.module}/ansible"
    }

    depends_on = [
        local_file.ansible-inventory
    ]
}
