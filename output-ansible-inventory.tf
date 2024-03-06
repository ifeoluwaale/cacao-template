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
