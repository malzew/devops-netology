# Домашнее задание к занятию "09.05 Gitlab"

## Подготовка к выполнению

1. Необходимо [зарегистрироваться](https://about.gitlab.com/free-trial/)
2. Создайте свой новый проект
3. Создайте новый репозиторий в gitlab, наполните его [файлами](./repository)
4. Проект должен быть публичным, остальные настройки по желанию

*Выполнено*

[Репозиторий проекта](https://gitlab.com/malzew/netology-python)

## Основная часть

### DevOps

В репозитории содержится код проекта на python. Проект - RESTful API сервис. Ваша задача автоматизировать сборку образа с выполнением python-скрипта:
1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)
2. Python версии не ниже 3.7
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`

*Для ускорения работы пайплайна, по сборке докер контейнера с сервисом, был собран промежуточный контейнер из Centos 7 и Python 3.7 и следующего [Dockerfile](https://gitlab.com/malzew/netology-python/-/blob/master/python37_on_centos7_docker/Dockerfile)*

```dockerfile
FROM centos:7

RUN yum update -y && yum install -y wget make gcc openssl-devel bzip2-devel && yum clean all

RUN mkdir /tmp/python && \
    cd /tmp/python && \
    wget -nv https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz && \
    tar xzf Python-3.7.9.tgz && \
    cd Python-3.7.9 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    ln -sfn /usr/local/bin/python3.7 /usr/bin/python3.7 && \
    ln -sfn /usr/local/bin/pip3.7 /usr/bin/pip3.7 && \
    rm -rf /tmp/python/
```

*[Контейнер размещен в репозитории проекта](https://gitlab.com/malzew/netology-python/container_registry/3395449)*


4. Создана директория `/python_api`
5. Скрипт из репозитория размещён в /python_api
6. Точка вызова: запуск скрипта

*Сборка контейнера из [Dockerfile](https://gitlab.com/malzew/netology-python/-/blob/master/Dockerfile)*

```dockerfile
FROM registry.gitlab.com/malzew/netology-python/centos7-python:3.7

RUN groupadd --gid 1000 service \
    && useradd --uid 1000 --gid 1000 --home-dir /python_api service

USER service

WORKDIR /python_api

COPY ./python_api/* /python_api/
COPY ./requirements.txt /python_api/requirements.txt

ENV PATH=$PATH:/python_api/.local/bin

RUN python3.7 -m pip install --upgrade pip && \
    pip3.7 install --upgrade setuptools && \
    pip3.7 install -r requirements.txt

EXPOSE 5290

CMD ["python3.7", "/python_api/python-api.py"]
```

7. Если сборка происходит на ветке `master`: Образ должен пушится в docker registry вашего gitlab `python-api:latest`, иначе этот шаг нужно пропустить

*[Настроенный пайплайн Gitlab](https://gitlab.com/malzew/netology-python/-/blob/master/.gitlab-ci.yml)*

```yaml
image: docker:stable

services:
  - docker:stable-dind

variables:
  DOCKER_TLS_CERTDIR: "/certs"

before_script:
  - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY

docker-build:
  stage: build
  script:
    - |
      if [[ "$CI_COMMIT_BRANCH" == "$CI_DEFAULT_BRANCH" ]]; then
        tag=""
        echo "Running on default branch '$CI_DEFAULT_BRANCH': tag = ':latest'"
      else
        tag=":$CI_COMMIT_REF_SLUG"
        echo "Running on branch '$CI_COMMIT_BRANCH': tag = $tag"
      fi
    - docker build --pull -t "$CI_REGISTRY_IMAGE/python-api${tag}" .
    - |
      if [[ "$CI_COMMIT_BRANCH" == "$CI_DEFAULT_BRANCH" ]]; then
        docker push "$CI_REGISTRY_IMAGE/python-api${tag}"
      fi

  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile
```

### Product Owner

Вашему проекту нужна бизнесовая доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:
1. Какой метод необходимо исправить
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
3. Issue поставить label: feature

https://gitlab.com/malzew/netology-python/-/issues/1

### Developer

Вам пришел новый Issue на доработку, вам необходимо:
1. Создать отдельную ветку, связанную с этим issue
2. Внести изменения по тексту из задания
3. Подготовить Merge Requst, влить необходимые изменения в `master`, проверить, что сборка прошла успешно

https://gitlab.com/malzew/netology-python/-/merge_requests/3

### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:
1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый

*Выполнено*

## Итог

После успешного прохождения всех ролей - отправьте ссылку на ваш проект в гитлаб, как решение домашнего задания

[Репозиторий проекта](https://gitlab.com/malzew/netology-python)

## Необязательная часть

Автомазируйте работу тестировщика, пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер и выполняет проверку, например, при помощи curl. На основе вывода - будет приниматься решение об успешности прохождения тестирования

*Добавлен следующий пайплайн на основе wget*

```yaml
docker-test:
  stage: test
  script:
    - |
      if [[ "$CI_COMMIT_BRANCH" == "$CI_DEFAULT_BRANCH" ]]; then
        tag=""
        echo "Running on default branch '$CI_DEFAULT_BRANCH': tag = ':latest'"
        docker run -d -p 5290:5290 --rm "$CI_REGISTRY_IMAGE/python-api${tag}"
        sleep 15
        wget -q --output-document - "http://docker:5290/get_info" | grep -q 'Already started'
        wget -q --output-document - "http://docker:5290/rest/api/get_info" | grep -q 'Running'
      else
        echo "Running on branch '$CI_COMMIT_BRANCH'"
        echo "No testing need"
      fi
```

*Пример работы пайплайна*

https://gitlab.com/malzew/netology-python/-/jobs/2977586273

