# Публичная сеть и ВМ
resource "yandex_vpc_network" "netology-network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "central1-a" {
  name           = "central1-a-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "central1-b" {
  name           = "central1-b-subnet"
  zone           = var.default_zone_b
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

data "yandex_compute_image" "public-ubuntu" {
  image_id = var.public_image
}

# Master VM
resource "yandex_compute_instance" "master" {
  name      = local.instance_master
  hostname  = local.instance_master
  
  platform_id = "standard-v1"
  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.public_resources.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

   network_interface {
    subnet_id     = yandex_vpc_subnet.central1-a.id
    nat           = true
    # Устанавливаем желаемый внутренний IP-адрес для master-ноды
    ip_address    = "10.0.1.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/new.rsa.pub")}"
  }

  # Подождать 10 секунд после создания
  provisioner "local-exec" {
    command = "sleep 10"  
  }
  
  provisioner "file" {
    source      = "/root/.ssh/new.rsa"
    destination = "/home/ubuntu/.ssh/new.rsa"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/root/.ssh/new.rsa")
      host        = self.network_interface[0].nat_ip_address
    }
  }

  provisioner "file" {
    source      = "/home/msi/diplom/ansible/"
    destination = "/home/ubuntu/"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/root/.ssh/new.rsa")
      host        = self.network_interface[0].nat_ip_address
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/root/.ssh/new.rsa")
      host        = self.network_interface[0].nat_ip_address
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "sudo pip3 install ansible",
      "chmod 600 /home/ubuntu/.ssh/new.rsa",
      "ansible-playbook -i /home/ubuntu/inventory.ini --become --become-user=root /home/ubuntu/cluster.yml",
    ]
  }
}
 
# Node VMs
resource "yandex_compute_instance" "node" {
  count = length(local.instance_nodes)
  name  = local.instance_nodes[count.index]
  hostname    = local.instance_nodes[count.index]
  
  platform_id = "standard-v1"
  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.public_resources.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id     = yandex_vpc_subnet.central1-a.id
    nat           = true
    # Устанавливаем желаемый внутренний IP-адрес для каждой ноды
    ip_address    = "10.0.1.${count.index + 11}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/new.rsa.pub")}"
  }
  
  # Подождать 10 секунд после создания
  provisioner "local-exec" {
    command = "sleep 10"
  }
}
  # Создаем сервисный аккаунт для bucket
resource "yandex_iam_service_account" "bucket-sa" {
  name        = "bucket-sa"
  description = "service account for bucket"
 }
 
  # Создаем роль для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
}

  # Создаем ключи для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}

  # Создаем bucket
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