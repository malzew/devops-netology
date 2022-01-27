# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | Никакое, будет ошибка |
| Как получить для переменной `c` значение 12?  | `c = str(a) + b` |
| Как получить для переменной `c` значение 3?  | `c = a + int(b)` |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
!/usr/bin/env python3

import os

rep_path = "~/netology/sysadm-homeworks"
bash_command = ["cd " + rep_path, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = rep_path + "/" + result.replace('\tmodified:   ', '')
        print(prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
~/netology/sysadm-homeworks/1
~/netology/sysadm-homeworks/2
~/netology/sysadm-homeworks/3
~/netology/sysadm-homeworks/dir1/dir1_1
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

if len(sys.argv) <= 1:
    print("Need 1 arg with repository path")
    exit(1)

rep_path = sys.argv[1]
if rep_path[len(rep_path)-1] == '/':
    rep_path = rep_path[:-1]

bash_command = ["cd " + rep_path, "git status 2>&1"]
result_os = os.popen(' && '.join(bash_command)).read()

if result_os.find('fatal: not a git repository') != -1:
    print (rep_path + ' not a git repository')
    exit(1)

is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = rep_path + "/" + result.replace('\tmodified:   ', '')
        print(prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
$ testrep.py ~/netology/sysadm-homeworks/

/home/andrey/netology/sysadm-homeworks/1
/home/andrey/netology/sysadm-homeworks/2
/home/andrey/netology/sysadm-homeworks/3
/home/andrey/netology/sysadm-homeworks/dir1/dir1_1
/home/andrey/netology/sysadm-homeworks/testrep.py
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time

urls = ['drive.google.com', 'mail.google.com', 'google.com']

dictip = { hname : socket.gethostbyname(hname) for hname in urls}

while True:
  for hname in dictip.keys():
    ipaddr = socket.gethostbyname(hname)
    print (hname + ' - ' + ipaddr)
    if dictip[hname] != ipaddr:
      print ('[ERROR] ' + hname + ' IP mismatch: ' + dictip[hname] + ' ' + ipaddr)
      dictip[hname] = ipaddr
  time.sleep(5)
```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 173.194.221.194
mail.google.com - 142.251.1.83
google.com - 64.233.165.139
drive.google.com - 173.194.221.194
mail.google.com - 142.251.1.83
google.com - 64.233.165.139
drive.google.com - 173.194.221.194
mail.google.com - 127.0.0.1
[ERROR] mail.google.com IP mismatch: 142.251.1.83 127.0.0.1
google.com - 64.233.165.139
drive.google.com - 173.194.221.194
mail.google.com - 127.0.0.1
google.com - 64.233.165.139
drive.google.com - 173.194.221.194
mail.google.com - 127.0.0.1
google.com - 64.233.165.139
drive.google.com - 173.194.221.194
mail.google.com - 127.0.0.1
google.com - 64.233.165.139
drive.google.com - 173.194.221.194
mail.google.com - 142.251.1.83
[ERROR] mail.google.com IP mismatch: 127.0.0.1 142.251.1.83
google.com - 64.233.165.139
drive.google.com - 173.194.221.194
mail.google.com - 142.251.1.83
google.com - 64.233.165.139
```
