output "master_ip" {
  value = yandex_compute_instance.master.network_interface[0].nat_ip_address
}

output "vm_external_ip_addresses" {
  value = {
    node1  = yandex_compute_instance.node[0].network_interface[0].nat_ip_address
    node2  = yandex_compute_instance.node[1].network_interface[0].nat_ip_address
  }
}

# output "pic_url" {
#  value = "https://${yandex_storage_bucket.vp-bucket.bucket_domain_name}"
#}


