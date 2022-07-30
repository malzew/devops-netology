# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

```commandline
$ sudo docker exec -ti mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"'
mysql> create database test_db;

$ sudo docker exec -i mysql sh -c 'exec mysql -D test_db -uroot -p"$MYSQL_ROOT_PASSWORD"' < test_dump.sql
```

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```commandline
$ sudo docker exec -ti mysql sh -c 'exec mysql -D test_db -uroot -p"$MYSQL_ROOT_PASSWORD"'
mysql> status
--------------
mysql  Ver 8.0.30 for Linux on x86_64 (MySQL Community Server - GPL)
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

```commandline
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

**Приведите в ответе** количество записей с `price` > 300.

```commandline
mysql> select count(*) from orders where price>300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

```commandline
mysql> CREATE USER 'test'
    -> IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> WITH MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"last_name": "Pretty", "first_name": "James"}';
Query OK, 0 rows affected (0.00 sec)
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

```commandline
mysql> grant select on test_db.* to 'test';
```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

```commandline
mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES where user = 'test';
+------+------+------------------------------------------------+
| USER | HOST | ATTRIBUTE                                      |
+------+------+------------------------------------------------+
| test | %    | {"last_name": "Pretty", "first_name": "James"} |
+------+------+------------------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

```commandline
mysql> show table status;
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| Name   | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time         | Check_time | Collation          | Checksum | Create_options | Comment |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| orders | InnoDB |      10 | Dynamic    |    5 |           3276 |       16384 |               0 |            0 |         0 |              6 | 2022-07-30 09:54:49 | 2022-07-30 09:54:49 | NULL       | utf8mb4_0900_ai_ci |     NULL |                |         |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
1 row in set (0.00 sec)
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`

*Ответ - 17 мс.*

- на `InnoDB`

*Ответ - 18 мс.*

```commandline
mysql> alter table orders engine = 'MyISAM';
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> alter table orders engine = 'InnoDB';
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+----------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                |
+----------+------------+----------------------------------------------------------------------+
|        1 | 0.00063575 | select * from INFORMATION_SCHEMA.USER_ATTRIBUTES where user = 'test' |
|        2 | 0.00162775 | show table status                                                    |
|        3 | 0.01795350 | alter table orders engine = 'MyISAM'                                 |
|        4 | 0.01825400 | alter table orders engine = 'InnoDB'                                 |
+----------+------------+----------------------------------------------------------------------+
4 rows in set, 1 warning (0.00 sec)

mysql> show profile for query 3;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000133 |
| Executing hook on transaction  | 0.000008 |
| starting                       | 0.000062 |
| checking permissions           | 0.000010 |
| checking permissions           | 0.000004 |
| init                           | 0.000019 |
| Opening tables                 | 0.000385 |
| setup                          | 0.000095 |
| creating table                 | 0.000707 |
| waiting for handler commit     | 0.000010 |
| waiting for handler commit     | 0.001507 |
| After create                   | 0.001626 |
| System lock                    | 0.000016 |
| copy to tmp table              | 0.000120 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.000022 |
| rename result table            | 0.000084 |
| waiting for handler commit     | 0.003796 |
| waiting for handler commit     | 0.000019 |
| waiting for handler commit     | 0.001941 |
| waiting for handler commit     | 0.000021 |
| waiting for handler commit     | 0.004408 |
| waiting for handler commit     | 0.000019 |
| waiting for handler commit     | 0.000305 |
| end                            | 0.001938 |
| query end                      | 0.000596 |
| closing tables                 | 0.000011 |
| waiting for handler commit     | 0.000017 |
| freeing items                  | 0.000037 |
| cleaning up                    | 0.000019 |
+--------------------------------+----------+
31 rows in set, 1 warning (0.00 sec)

mysql> show profile for query 3;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000133 |
| Executing hook on transaction  | 0.000008 |
| starting                       | 0.000062 |
| checking permissions           | 0.000010 |
| checking permissions           | 0.000004 |
| init                           | 0.000019 |
| Opening tables                 | 0.000385 |
| setup                          | 0.000095 |
| creating table                 | 0.000707 |
| waiting for handler commit     | 0.000010 |
| waiting for handler commit     | 0.001507 |
| After create                   | 0.001626 |
| System lock                    | 0.000016 |
| copy to tmp table              | 0.000120 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.000022 |
| rename result table            | 0.000084 |
| waiting for handler commit     | 0.003796 |
| waiting for handler commit     | 0.000019 |
| waiting for handler commit     | 0.001941 |
| waiting for handler commit     | 0.000021 |
| waiting for handler commit     | 0.004408 |
| waiting for handler commit     | 0.000019 |
| waiting for handler commit     | 0.000305 |
| end                            | 0.001938 |
| query end                      | 0.000596 |
| closing tables                 | 0.000011 |
| waiting for handler commit     | 0.000017 |
| freeing items                  | 0.000037 |
| cleaning up                    | 0.000019 |
+--------------------------------+----------+
31 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

```commandline
$ sudo docker exec -ti mysql sh
sh-4.4# cat /etc/my.cnf
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M

# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/
```

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

```commandline
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# Ставим размер буфера 30% ОЗУ 8Гб*0.3=2400M
innodb_buffer_pool_size = 2400M

# Размер файла логов операций 100 Мб
innodb_log_file_size = 100M

# Размер буффера с незакомиченными транзакциями 1 Мб
innodb_log_buffer_size = 1M

# Скорость IO важнее сохранности данных
innodb_flush_log_at_trx_commit = 2

# Нужна компрессия таблиц для экономии места на диске
innodb_file_per_table = 1

#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M

# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
