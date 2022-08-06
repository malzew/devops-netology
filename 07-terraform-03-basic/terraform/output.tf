output "external_ip_address_count_yandex_cloud" {
  value = yandex_compute_instance.count[*].network_interface[0].nat_ip_address
}


output "external_ip_address_foreach_yandex_cloud" {
  value = { for k, v in yandex_compute_instance.foreach: k => v.network_interface[0].nat_ip_address }
}

output "YC_cloud_ID" {
  value = data.yandex_client_config.client.cloud_id
}

output "YC_folder_ID" {
  value = data.yandex_client_config.client.folder_id
}

output "YC_zone" {
  value = data.yandex_client_config.client.zone
}

output "internal_ip_address_count_yandex_cloud" {
  value = yandex_compute_instance.count[*].network_interface[0].ip_address
}

output "internal_ip_address_foreach_yandex_cloud" {
  value = { for k, v in yandex_compute_instance.foreach: k => v.network_interface[0].ip_address }
}

output "subnet_id" {
  value = yandex_vpc_subnet.default.network_id
}
