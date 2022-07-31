# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД

```commandline
$ sudo docker exec -ti postgres psql -U postgres
psql (13.7 (Debian 13.7-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

- подключения к БД

```commandline
postgres=# \c postgres
You are now connected to database "postgres" as user "postgres".
```

- вывода списка таблиц

```commandline
postgres=# create table a (id int);
CREATE TABLE
postgres=# \dt
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | a    | table | postgres
(1 row)
```

- вывода описания содержимого таблиц

```commandline
postgres=# \d a
                 Table "public.a"
 Column |  Type   | Collation | Nullable | Default 
--------+---------+-----------+----------+---------
 id     | integer |           |          | 
```

- выхода из psql

```commandline
postgres=# \q
```

## Задача 2

Используя `psql` создайте БД `test_database`.

```commandline
$ sudo # docker exec -ti postgres psql -U postgres
psql (13.7 (Debian 13.7-1.pgdg110+1))
Type "help" for help.

postgres=# create database test_database;
CREATE DATABASE
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

```commandline
$ sudo docker exec -i postgres sh -c 'exec psql -d test_database -U postgres ' < test_dump.sql
```

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

```commandline
ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```commandline
select attname, avg_width from pg_stats where tablename='orders' order by avg_width desc limit 1;
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

```sql
begin;
--Создаем таблицу и секции
create table orders_new (id int not null default nextval('public.orders_id_seq'::regclass), title varchar(80) not null, price int) partition by range(price);
create table orders_1 partition of orders_new (id with options not null default nextval('public.orders_id_seq'::regclass) primary key, title with options not null, price) for values from (500) to (MAXVALUE);
create table orders_2 partition of orders_new (id with options not null default nextval('public.orders_id_seq'::regclass) primary key, title with options not null, price) for values from (MINVALUE) to (500);
--Переносим данные в новую таблицу
insert into orders_new (id, title, price) select * from orders;
--Ставим владельцем секвенса новую таблицу
alter sequence public.orders_id_seq owned by public.orders_new.id;
--Переименовываем таблицы
alter table orders rename to orders_old;
alter table orders_new rename to orders;
--Дропаем старую таблицу
drop table orders_old;
commit;
```

*Результаты выполнения:*

```
test_database=# \d
                   List of relations
 Schema |     Name      |       Type        |  Owner   
--------+---------------+-------------------+----------
 public | orders        | partitioned table | postgres
 public | orders_1      | table             | postgres
 public | orders_2      | table             | postgres
 public | orders_id_seq | sequence          | postgres
(4 rows)

test_database=# \d+ orders
                                                 Partitioned table "public.orders"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 title  | character varying(80) |           | not null |                                    | extended |              | 
 price  | integer               |           |          |                                    | plain    |              | 
Partition key: RANGE (price)
Partitions: orders_1 FOR VALUES FROM (500) TO (MAXVALUE),
            orders_2 FOR VALUES FROM (MINVALUE) TO (500)

test_database=# \d+ orders_1
                                                      Table "public.orders_1"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 title  | character varying(80) |           | not null |                                    | extended |              | 
 price  | integer               |           |          |                                    | plain    |              | 
Partition of: orders FOR VALUES FROM (500) TO (MAXVALUE)
Partition constraint: ((price IS NOT NULL) AND (price >= 500))
Indexes:
    "orders_1_pkey" PRIMARY KEY, btree (id)
Access method: heap

test_database=# \d+ orders_2
                                                      Table "public.orders_2"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 title  | character varying(80) |           | not null |                                    | extended |              | 
 price  | integer               |           |          |                                    | plain    |              | 
Partition of: orders FOR VALUES FROM (MINVALUE) TO (500)
Partition constraint: ((price IS NOT NULL) AND (price < 500))
Indexes:
    "orders_2_pkey" PRIMARY KEY, btree (id)
Access method: heap

test_database=# select * from orders;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)

test_database=# select * from orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# select * from orders_2;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

*Можно было сделать секционирование таблицы изначально. Если это сделать с наследованием и триггерами, можно полностью автоматизировать создание секций.* 

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```commandline
$ sudo docker exec -i postgres sh -c 'exec pg_dump -d test_database -U postgres ' > test_dump_new.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

*Добавил бы ограничение уникальности на title. Но это в данном случае это сработает только для отдельных частей таблицы, так как значение price, по которому проходит секционирование не уникально.*

*Поэтому, добавим в конец файла:*

```sql
ALTER TABLE public.orders_1 ADD UNIQUE(title);
ALTER TABLE public.orders_2 ADD UNIQUE(title);
```

```
test_database=# \d+ orders_1
                                                      Table "public.orders_1"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 title  | character varying(80) |           | not null |                                    | extended |              | 
 price  | integer               |           |          |                                    | plain    |              | 
Partition of: orders FOR VALUES FROM (500) TO (MAXVALUE)
Partition constraint: ((price IS NOT NULL) AND (price >= 500))
Indexes:
    "orders_1_pkey" PRIMARY KEY, btree (id)
    "orders_1_title_key" UNIQUE CONSTRAINT, btree (title)
Access method: heap

test_database=# \d+ orders_2
                                                      Table "public.orders_2"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 title  | character varying(80) |           | not null |                                    | extended |              | 
 price  | integer               |           |          |                                    | plain    |              | 
Partition of: orders FOR VALUES FROM (MINVALUE) TO (500)
Partition constraint: ((price IS NOT NULL) AND (price < 500))
Indexes:
    "orders_2_pkey" PRIMARY KEY, btree (id)
    "orders_2_title_key" UNIQUE CONSTRAINT, btree (title)
Access method: heap
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
