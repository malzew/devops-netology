Elasticsearch
=========

Ansible simple role to install Elasticsearch from remote server.

Role Variables
--------------

| Variable name | Default                                                   | Description                                                                        |
|--------------|-----------------------------------------------------------|------------------------------------------------------------------------------------|
| elastic_url | "{{ elastic[8] }}"                                        | This vaiable use dict from `/vars/main.yml`                                        |
| elastic_distr_name | elastic-8-linux.tar.gz                                    | Name of destination archive                                                        |
| elastic_folder | {{ elastic_distr_name.split('-')[:2] &#124; join('-')  }} | Name of directory to unarchive. By default it used jinja template from archive name |
| elastic_home | "/opt/elastic/{{ elastic_folder }}"                               | Specify ES_HOME environment                                                        |

Example Playbook
----------------

```yaml
- hosts: all
  roles:
      - malzew.elasticsearch
```

License
-------

BSD

Author Information
------------------

Andrey Maltsev
