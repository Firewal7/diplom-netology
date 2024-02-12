# Master VM
resource "yandex_compute_instance" "master" {
  name      = local.instance_master
  hostname  = local.instance_master
  zone      = var.default_zone_a 
  
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
    ip_address    = "10.0.1.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/new.rsa.pub")}"
  }

# Подождать 15 секунд после создания
  provisioner "local-exec" {
    command = "sleep 15"  
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
      "ansible-playbook -i /home/ubuntu/inventory/inventory.ini --become --become-user=root /home/ubuntu/playbooks/cluster.yml",  # Установка кластера через kubespray
      "sleep 200",  # Задержка в 200 секунд
      "ansible-playbook -i /home/ubuntu/inventory/inventory.ini --become --become-user=root /home/ubuntu/playbooks/teamcity.yml",  # Установка teamcity-server; teamcity-agent
      "sleep 120",  # Задержка в 120 секунд
      "ansible-playbook -i /home/ubuntu/inventory/inventory.ini --become --become-user=root /home/ubuntu/playbooks/postgresql.yml",  # Установка postgresql на ВМ teamcity-server
    ]
  }
}
 
# Node1 VM
resource "yandex_compute_instance" "node1" {
  name      = local.instance_node1
  hostname  = local.instance_node1
  zone      = var.default_zone_b
  
  platform_id = "standard-v1"
  resources {
    cores         = var.public_resources_node.cores
    memory        = var.public_resources_node.memory
    core_fraction = var.public_resources_node.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.public_resources_node.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

   network_interface {
    subnet_id     = yandex_vpc_subnet.central1-b.id
    nat           = true
    ip_address    = "10.0.2.11"
  } 

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/new.rsa.pub")}"
  }
}
# Node2 VM
resource "yandex_compute_instance" "node2" {
  name      = local.instance_node2
  hostname  = local.instance_node2
  zone      = var.default_zone_c
  
  platform_id = "standard-v1"
  resources {
    cores         = var.public_resources_node.cores
    memory        = var.public_resources_node.memory
    core_fraction = var.public_resources_node.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.public_resources_node.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

   network_interface {
    subnet_id     = yandex_vpc_subnet.central1-c.id
    nat           = true
    ip_address    = "10.0.3.12"
  } 

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/new.rsa.pub")}"
  } 
}

# Teamcity-Server
resource "yandex_compute_instance" "teamsity-server" {
  name      = local.instance_teamsity-server
  hostname  = local.instance_teamsity-server
  zone      = var.default_zone_a
  
  platform_id = "standard-v1"
  resources {
    cores         = var.teamcity_resources_server.cores
    memory        = var.teamcity_resources_server.memory
    core_fraction = var.teamcity_resources_server.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.teamcity_resources_server.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

   network_interface {
    subnet_id     = yandex_vpc_subnet.central1-a.id
    nat           = true
    ip_address    = "10.0.1.44"
  } 

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/new.rsa.pub")}"
  } 
}

# Teamcity-Agent
resource "yandex_compute_instance" "teamsity-agent" {
  name      = local.instance_teamsity-agent
  hostname  = local.instance_teamsity-agent
  zone      = var.default_zone_a
  
  platform_id = "standard-v1"
  resources {
    cores         = var.teamcity_resources_agent.cores
    memory        = var.teamcity_resources_agent.memory
    core_fraction = var.teamcity_resources_agent.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.teamcity_resources_agent.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

   network_interface {
    subnet_id     = yandex_vpc_subnet.central1-a.id
    nat           = true
    ip_address    = "10.0.1.34"
  } 

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/new.rsa.pub")}"
  } 
}