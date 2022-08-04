output "external_ip_address_node01_yandex_cloud" {
  value = "${yandex_compute_instance.node-01.network_interface.0.nat_ip_address}"
}

output "YC_cloud_ID" {
  value = "${data.yandex_client_config.client.cloud_id}"
}

output "YC_folder_ID" {
  value = "${data.yandex_client_config.client.folder_id}"
}

output "YC_zone" {
  value = "${data.yandex_client_config.client.zone}"
}

output "internal_ip_address_node01_yandex_cloud" {
  value = "${yandex_compute_instance.node-01.network_interface.0.ip_address}"
}

output "subnet_id" {
  value = "${yandex_vpc_subnet.default.network_id}"
}
