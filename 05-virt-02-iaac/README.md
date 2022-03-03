
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

---

Добрый день!  
Домашнее задание будет выполнено в виде ответов по пунктам  
Ответы на вопросы выделены *курсивом*

---

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.

    *Основные преимущества применения IaaC паттернов:*  
    *1. Ускорение предоставления инфраструктуры для разработки и вывода продукта на рынок.*  
    *2. Стабильность среды, устранение дрейфа конфигураций, приводящего к несовпадению сред разработки, тестирования и боевой среды.*  
    *3. Более быстрая разработка, за счет более быстрого предоставления среды на каждом этапе.*

- Какой из принципов IaaC является основополагающим?

  *Идемпотентность — это свойство объекта или операции, при повторном выполнении которой, мы получаем результат идентичный предыдущему.*  
  *Принципы IaC позволяют не фокусироваться на рутине, а заниматься более важными задачами. Автоматизация инфраструктуры позволяет эффективнее использовать существующие ресурсы. Также автоматизация позволяет минимизировать риск возникновения человеческой ошибки.*

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?

  *- На управляемые узлы не нужно устанавливать никакого дополнительного ПО, всё работает через SSH (в случае необходимости дополнительные модули можно взять из официального репозитория)*  
  *- Код программы, написанный на Python, очень прост; при необходимости написание дополнительных модулей не составляет особого труда*  
  *- Язык, на котором пишутся сценарии, также предельно прост*

- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

  *На мой взгляд более надежен push метод, так как по ходу дела проверяется состояние ноды. Это гарантирует консистентность боевой среды.*

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

```
$ virtualbox --help

Oracle VM VirtualBox VM Selector v6.1.26_Ubuntu
(C) 2005-2021 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
```

```
$ vagrant version

Installed Version: 2.2.19
Latest Version: 2.2.19
 
You're running an up-to-date version of Vagrant!
```

```
$ ansible --version

ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/andrey/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды

```
docker ps
```

```
$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Importing base box 'bento/ubuntu-20.04'...
==> server1.netology: Matching MAC address for NAT networking...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202107.28.0' is up to date...
==> server1.netology: Setting the name of the VM: server1.netology
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology: 
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology: 
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /home/andrey/devops-netology/05-virt-02-iaac/src/vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
changed: [server1.netology]

TASK [Adding ed25519-key in /root/.ssh/authorized_keys] ************************
changed: [server1.netology]

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=['git', 'curl'])

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

$ vagrant ssh
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 System information disabled due to load higher than 1.0


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Thu Mar  3 17:33:43 2022 from 10.0.2.2
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
