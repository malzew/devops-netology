provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1g2n2okvr289487oale"
  folder_id = "b1gg33hbpnn7at4oorel"
  zone      = "ru-central1-a"
}

# Получим данные клиента
data "yandex_client_config" "client" {}

# Образ берем стандартный, предоставляемый Яндексом, по семейству
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

# Создаем сеть
resource "yandex_vpc_network" "default" {
  name = "net"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "default" {
  zone       = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.150.0/24"]
}

locals {
  node_instance_type_map = {
    stage = "standard-v1"
    prod  = "standard-v2"
  }

  node_instance_count_map = {
    stage = 1
    prod  = 2
  }

  node_instance_foreach_map = {
    "foreach-01" = "ru-central1-a"
    "foreach-02" = "ru-central1-a"
  }
}

# Создаем ВМ, задаем имя, платформу, зону, имя хоста с помощью count
resource "yandex_compute_instance" "count" {
  name        = "count-${count.index+1}"
  platform_id = local.node_instance_type_map[terraform.workspace]
  zone        = "ru-central1-a"
  hostname    = "count-${count.index+1}.netology.yc"
  count = local.node_instance_count_map[terraform.workspace]

  # В ресурсах 2 ядра, 4 гига оперативы, под 100% нагрузку
  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  # Загрузочный диск из стандартного образа, на SSD, 40Gb
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-hdd"
      size = "20"
    }
  }

  # Это нужно, чтобы при смене id образа (сменилась последняя сборка семейства ОС) терраформ не пытался пересоздать ВМ
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }

  # Создаем сетевой интерфейс у ВМ, с адресом из ранее созданной подсети и NAT, чтобы был доступ в инет
  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
      nat = "true"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Создаем ВМ, задаем имя, платформу, зону, имя хоста с помощью for_each
resource "yandex_compute_instance" "foreach" {
  name        = each.key
  platform_id = local.node_instance_type_map[terraform.workspace]
  zone        = each.value
  hostname    = "${each.key}.netology.yc"
  for_each    = local.node_instance_foreach_map

  # В ресурсах 2 ядра, 4 гига оперативы, под 100% нагрузку
  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  # Загрузочный диск из стандартного образа, на SSD, 40Gb
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-hdd"
      size = "20"
    }
  }

  # Это нужно, чтобы при смене id образа (сменилась последняя сборка семейства ОС) терраформ не пытался пересоздать ВМ
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]

    #Создать новый ресурс перед удалением старого
    create_before_destroy = true
  }

  # Создаем сетевой интерфейс у ВМ, с адресом из ранее созданной подсети и NAT, чтобы был доступ в инет
  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
      nat = "true"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}