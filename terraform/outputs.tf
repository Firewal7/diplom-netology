output "master_internal_ipv4" {
  value = yandex_compute_instance.master.network_interface[0].ip_address
}

output "node1_internal_ipv4" {
  value = yandex_compute_instance.node1.network_interface[0].ip_address
}

output "node2_internal_ipv4" {
  value = yandex_compute_instance.node2.network_interface[0].ip_address
}

output "teamsity-server_internal_ipv4" {
  value = yandex_compute_instance.teamsity-server.network_interface[0].ip_address
}

output "teamsity-agent_internal_ipv4" {
  value = yandex_compute_instance.teamsity-agent.network_interface[0].ip_address
}

output "pic_url" {
  value = "https://${yandex_storage_bucket.backend-encrypted.bucket}.storage.yandexcloud.net"
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.bucket-static_access_key.access_key
}

output "kms_key_id" {
  value = yandex_kms_symmetric_key.key-a.id
}