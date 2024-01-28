output "master_internal_ipv4" {
  value = yandex_compute_instance.master.network_interface[0].ip_address
}

output "node_internal_ipv4s" {
  value = [for instance in yandex_compute_instance.node : instance.network_interface[0].ip_address]
}

 output "pic_url" {
  value = "https://${yandex_storage_bucket.vp-bucket.bucket_domain_name}"
}


