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

# Создаем ВМ, задаем имя, платформу, зону, имя хоста
resource "yandex_compute_instance" "node-01" {
  name        = "node-01"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "node-01.netology.yc"

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
      type = "network-ssd"
      size = "40"
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