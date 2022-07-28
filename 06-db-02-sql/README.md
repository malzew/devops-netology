# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```yaml
version: "2.1"
services:
  postgres:
    image: postgres:14.4
    environment:
      POSTGRES_USER: "su"
      POSTGRES_PASSWORD: "superpass"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - /opt/postgresql/backup:/var/lib/postgresql/backup
      - /opt/postgresql/data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```



## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

```sql
CREATE DATABASE test_db ENCODING 'UTF8';
CREATE USER "test-admin-user";
CREATE TABLE orders (id serial PRIMARY KEY, наименование VARCHAR, цена INT); 
CREATE TABLE clients (id serial PRIMARY KEY, фамилия VARCHAR, "страна проживания" VARCHAR, заказ INT REFERENCES orders(id)); 
CREATE INDEX ON clients("страна проживания");
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
CREATE USER "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";
```

Приведите:
- итоговый список БД после выполнения пунктов выше,

```commandline
$ psql -h localhost -U su
Password for user su: 
psql (12.11 (Ubuntu 12.11-0ubuntu0.20.04.1), server 14.4 (Debian 14.4-1.pgdg110+1))
WARNING: psql major version 12, server major version 14.
         Some psql features might not work.
Type "help" for help.

su=# \l
                             List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    | Access privileges 
-----------+-------+----------+------------+------------+-------------------
 postgres  | su    | UTF8     | en_US.utf8 | en_US.utf8 | 
 su        | su    | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | su    | UTF8     | en_US.utf8 | en_US.utf8 | =c/su            +
           |       |          |            |            | su=CTc/su
 template1 | su    | UTF8     | en_US.utf8 | en_US.utf8 | =c/su            +
           |       |          |            |            | su=CTc/su
 test_db   | su    | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/su           +
           |       |          |            |            | su=CTc/su
(5 rows)
```

- описание таблиц (describe)

```commandline
su=# \c test_db
psql (12.11 (Ubuntu 12.11-0ubuntu0.20.04.1), server 14.4 (Debian 14.4-1.pgdg110+1))
WARNING: psql major version 12, server major version 14.
         Some psql features might not work.
You are now connected to database "test_db" as user "su".
test_db=# \d
             List of relations
 Schema |      Name      |   Type   | Owner 
--------+----------------+----------+-------
 public | clients        | table    | su
 public | clients_id_seq | sequence | su
 public | orders         | table    | su
 public | orders_id_seq  | sequence | su
(4 rows)

test_db=# \d orders
                                    Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default               
--------------+-------------------+-----------+----------+------------------------------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying |           |          | 
 цена         | integer           |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=# \d clients
                                       Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default               
-------------------+-------------------+-----------+----------+-------------------------------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying |           |          | 
 страна проживания | character varying |           |          | 
 заказ             | integer           |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_страна проживания_idx" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```commandline
test_db=# SELECT * FROM information_schema.table_privileges WHERE grantee IN ('test-admin-user','test-simple-user');
 grantor |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
---------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 su      | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
 su      | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
 su      | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 su      | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
 su      | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 su      | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 su      | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 su      | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 su      | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 su      | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 su      | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
(11 rows)
```

- список пользователей с правами над таблицами test_db

```commandline
test_db=# \du
                                       List of roles
    Role name     |                         Attributes                         | Member of 
------------------+------------------------------------------------------------+-----------
 su               | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 test-admin-user  |                                                            | {}
 test-simple-user |                                                            | {}
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
