# Домашнее задание к занятию "08.03 Работа с Roles"

## Решение

По заданию подготовлены роли для установки Elasticsearch и Kibana.

Окружение создано на основе докер контейнеров CentOS 7. Окружение учебное, после отработки playbook запуск сервисов необходимо сделать в ручном режиме.

В первом окне:
```commandline
# docker run -it --rm --name elastic01 -p 9200:9200 centos:7
```

Во втором окне:
```commandline
# docker run -it --rm --name kibana01 -p 5601:5601 centos:7
```

[Playbook](./site.yml)

Доступные теги - java, elastic, kibana.

   * java - Роль с этим тегом выполняют установку Java на целевые хосты.
   * elastic - Роль с этим тегом выполняют установку Elasticsearch на целевые хосты. 
   * kibana - Роль с этим тегом выполняют установку Kibana на целевые хосты. 

Роли и ссылки на репозитории прописаны в файле

[Requirements](./requirements.yml)