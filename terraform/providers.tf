terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"

# Блок конфигурации backend S3  
#  backend "s3" {
#    endpoint                    = "storage.yandexcloud.net"
#    bucket                      = "sofin-diplom-bucket-2024"
#    region                      = "ru-central1"
#    key                         = "tfstate"
#    skip_region_validation      = true
#    skip_credentials_validation = true
# }
}

# Блок конфигурации провайдера Yandex.Cloud
provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

data "yandex_compute_image" "public-ubuntu" {
  image_id = var.public_image
}