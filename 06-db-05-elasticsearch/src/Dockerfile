FROM centos:7

ENV ES_HOME=/opt/elasticsearch
ENV ES_VERSION=8.3.3

RUN yum install -y wget perl-Digest-SHA sudo && yum clean all

RUN mkdir $ES_HOME \
    && groupadd --gid 1000 elasticsearch \
    && useradd --uid 1000 --gid 1000 --home-dir $ES_HOME elasticsearch \
    && mkdir /var/lib/elasticsearch \
    && chown -R elasticsearch:elasticsearch $ES_HOME \
    && chown -R elasticsearch:elasticsearch /var/lib/elasticsearch

USER elasticsearch

WORKDIR $ES_HOME

RUN  wget -nv http://192.168.10.164/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz \
     && wget -nv http://192.168.10.164/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz.sha512 \
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