# Публичная сеть и ВМ
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "central1-a" {
  name           = "central1-a"
  zone           = var.default_zone_a
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "central1-b" {
  name           = "central1-b"
  zone           = var.default_zone_b
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

resource "yandex_vpc_subnet" "central1-c" {
  name           = "central1-c"
  zone           = var.default_zone_c
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}
