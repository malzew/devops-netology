# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

 *Файл group_vars/all/examp.yml*

```commandline
$ cat group_vars/all/examp.yml 
---
  some_fact: '12'
```

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

`$ ansible-playbook -i inventory/test.yml site.yml `

3. Какой командой можно зашифровать файл?

`$ ansible-vault encrypt <file>`

4. Какой командой можно расшифровать файл?

`$ ansible-vault decrypt <file>`

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

`$ ansible-vault view <file>`

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

`$ ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml`

7. Как называется модуль подключения к host на windows?

`winrm`

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

`$ ansible-doc -t connection -l`

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

```commandline
- remote_user
        User name with which to login to the remote server, normally set by the remote_user keyword.
        If no user is supplied, Ansible will let the SSH client binary choose the user as it normally.
        [Default: (null)]
        set_via:
          cli:
          - name: user
            option: --user
          env:
          - name: ANSIBLE_REMOTE_USER
          ini:
          - key: remote_user
            section: defaults
          keyword:
          - name: remote_user
          vars:
          - name: ansible_user
          - name: ansible_ssh_user
```