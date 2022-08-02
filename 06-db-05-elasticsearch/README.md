# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста

```commandline
FROM centos:7

ENV ES_HOME=/opt/elasticsearch
ENV ES_VERSION=8.3.3

RUN yum install -y wget perl-Digest-SHA && yum clean all

RUN mkdir $ES_HOME \
    && groupadd --gid 1000 elasticsearch \
    && useradd --uid 1000 --gid 1000 --home-dir $ES_HOME elasticsearch \
    && mkdir /var/lib/elasticsearch \
    && chown -R elasticsearch:elasticsearch $ES_HOME \
    && chown -R elasticsearch:elasticsearch /var/lib/elasticsearch

USER elasticsearch

WORKDIR $ES_HOME

RUN  wget -nv https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz \
     && wget -nv https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz.sha512 \
     && shasum -a 512 -c elasticsearch-$ES_VERSION-linux-x86_64.tar.gz.sha512 \
     && tar -xzf elasticsearch-$ES_VERSION-linux-x86_64.tar.gz \
     && rm -f elasticsearch-$ES_VERSION-linux-x86_64.tar.gz \
     && mv -f elasticsearch-$ES_VERSION/* ./ \
     && rmdir elasticsearch-$ES_VERSION

RUN mkdir /var/lib/elasticsearch/data \
    && mkdir /var/lib/elasticsearch/logs \
    && mkdir $ES_HOME/snapshots

COPY ./elasticsearch.yml $ES_HOME/config/elasticsearch.yml
COPY ./docker-entrypoint $ES_HOME/docker-entrypoint

EXPOSE 9200

ENTRYPOINT ["./docker-entrypoint"]
```

```commandline
#!/bin/bash
set -e

export ES_JAVA_OPTS="-Xms1g -Xmx1g"

exec "$ES_HOME/bin/elasticsearch"
```
- ссылку на образ в репозитории dockerhub

https://hub.docker.com/r/malzew/elasticsearch

- ответ `elasticsearch` на запрос пути `/` в json виде

```dockerfile
$ curl -u elastic:$ELASTIC_KEY -k https://localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "elastic_cluster",
  "cluster_uuid" : "6Oy0b-VATviugWroySchAA",
  "version" : {
    "number" : "8.3.3",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "801fed82df74dbe537f89b71b098ccaff88d2c56",
    "build_date" : "2022-07-23T19:30:09.227964828Z",
    "build_snapshot" : false,
    "lucene_version" : "9.2.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```commandline
$ curl -X GET -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_cat/indices"
yellow open ind-2 clux0_z_RL2i2zDueLWhRg 2 1 0 0 450b 450b
green  open ind-1 ygofoyaGSIyLx-bZDdKf_g 1 0 0 0 225b 225b
yellow open ind-3 3qgAnGtvSUa8Dhs0h2Jd3w 4 2 0 0 900b 900b
```

Получите состояние кластера `elasticsearch`, используя API.

```commandline
$ curl -X GET -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_cluster/health"
{"cluster_name":"elastic_cluster","status":"yellow","timed_out":false,"number_of_nodes":1,"number_of_data_nodes":1,"active_primary_shards":9,"active_shards":9,"relocating_shards":0,"initializing_shards":0,"unassigned_shards":10,"delayed_unassigned_shards":0,"number_of_pending_tasks":0,"number_of_in_flight_fetch":0,"task_max_waiting_in_queue_millis":0,"active_shards_percent_as_number":47.368421052631575}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

*Потому, что у индексов со сконфигурированными репликами нет этих реплик, так как в кластере всего 1 нода. Поэтому же кластер в желтом состянии.* 

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```commandline
curl -X PUT -u elastic:$ELASTIC_KEY -k "https://localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/opt/elasticsearch/snapshots/netology_backup"
  }
}

{
  "acknowledged" : true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```commandline
curl -X PUT -u elastic:$ELASTIC_KEY -k "https://localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}

{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}

$ curl -X GET -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_cat/indices"
green open test 6Mj4tFKORQqqJXiCse1nZA 1 0 0 0 225b 225b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

```commandline
$ curl -X PUT -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_snapshot/netology_backup/snapshot_test?wait_for_completion=true"
{"snapshot":{"snapshot":"snapshot_test","uuid":"L6w10dg-R4aRBirPcikYAA","repository":"netology_backup","version_id":8030399,"version":"8.3.3","indices":[".geoip_databases","test",".security-7"],"data_streams":[],"include_global_state":true,"state":"SUCCESS","start_time":"2022-08-02T14:16:55.574Z","start_time_in_millis":1659449815574,"end_time":"2022-08-02T14:16:56.576Z","end_time_in_millis":1659449816576,"duration_in_millis":1002,"failures":[],"shards":{"total":3,"failed":0,"successful":3},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]},{"feature_name":"security","indices":[".security-7"]}]}}
```

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```commandline
bash-4.2$ cd netology_backup/
bash-4.2$ ls -l
total 36
-rw-r--r-- 1 elasticsearch elasticsearch  1098 Aug  2 14:16 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Aug  2 14:16 index.latest
drwxr-xr-x 5 elasticsearch elasticsearch  4096 Aug  2 14:16 indices
-rw-r--r-- 1 elasticsearch elasticsearch 18613 Aug  2 14:16 meta-L6w10dg-R4aRBirPcikYAA.dat
-rw-r--r-- 1 elasticsearch elasticsearch   386 Aug  2 14:16 snap-L6w10dg-R4aRBirPcikYAA.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```commandline
$ curl -X DELETE -k -u elastic:$ELASTIC_KEY "https://localhost:9200/test"
{"acknowledged":true}

curl -X PUT -u elastic:$ELASTIC_KEY -k "https://localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}

{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test2"
}

$ curl -X GET -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_cat/indices"
green open test-2 qjf6iAzoRWyvW-IfItrHCQ 1 0 0 0 225b 225b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```commandline
$ curl -X PUT -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "action.destructive_requires_name": false
  }
}

{
  "acknowledged" : true,
  "persistent" : {
    "action" : {
      "destructive_requires_name" : "false"
    }
  },
  "transient" : { }
}

$ curl -X DELETE -k -u elastic:$ELASTIC_KEY "https://localhost:9200/*?expand_wildcards=all"
{"acknowledged":true}

$ curl -X POST -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_snapshot/netology_backup/snapshot_test/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "*",
  "include_global_state": true
}

{
  "accepted" : true
}

$ curl -X GET -k -u elastic:$ELASTIC_KEY "https://localhost:9200/_cat/indices"
green open test XGrTE5n2QLyjWQh4BihIQg 1 0 0 0 225b 225b
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
