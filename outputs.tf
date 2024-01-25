output "vm_external_ip_address_public" {
  value = [for instance in yandex_compute_instance.public-instance : instance.network_interface[0].ip_address]
}

output "pic-url" {
  value = "https://${yandex_storage_bucket.vp-bucket.bucket_domain_name}"
}