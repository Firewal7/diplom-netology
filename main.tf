# Публичная сеть и ВМ
resource "yandex_vpc_network" "netology-network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "central1-a" {
  name           = "central1-a-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "central1-b" {
  name           = "central1-b-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

resource "yandex_vpc_subnet" "central1-c" {
  name           = "central1-c-subnet"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}

data "yandex_compute_image" "public-ubuntu" {
  image_id = var.public_image
}

resource "yandex_compute_instance" "public-instance" {
  count = 3  # Создать 3 виртуальные машины

  name        = element(["master", "node1", "node2"], count.index)
  hostname    = element(["master", "node1", "node2"], count.index)
  platform_id = "standard-v1"
  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.public-ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.central1-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/id.rsa.pub")}"
  }

  provisioner "local-exec" {
    command = "sleep 60"  # Подождать 60 секунд
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"  # Пользователь для подключения к инстансу
      private_key = file("/root/.ssh/id.rsa")  # Путь к вашему приватному ключу
      host = self.network_interface[0].nat_ip_address

    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ansible",
      "ansible-playbook -i ~/home/msi/diplom/ansible/inventory.ini --become --become-user=root ~/home/msi/diplom/ansible/cluster.yml"
    ]
  }
}

# Service account for bucket
resource "yandex_iam_service_account" "bucket-sa" {
  name        = "bucket-sa"
  description = "service account for bucket"
}

# Role for service account
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
}

# Keys for service account
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}

# Create bucket
resource "yandex_storage_bucket" "vp-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "sofin-netology-bucket-2024"

  max_size = 1073741824 # 1 Gb

  anonymous_access_flags {
    read = true
    list = false
  }
}
