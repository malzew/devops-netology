Kibana
=========

Ansible simple role to install kibana from remote server.

Role Variables
--------------

| Variable name      | Default                                                 | Description                                                                         |
|--------------------|---------------------------------------------------------|-------------------------------------------------------------------------------------|
| kibana_url         | `{{ kibana[8] }}`                                        | This vaiable use dict from `/vars/main.yml`                                         |
| kibana_distr_name | `kibana-8-linux.tar.gz`                                 | Name of destination archive                                                         |
| kibana_folder     | `{{ kibana_distr_name.split('-')[:2] &#124; join('-')  }}` | Name of directory to unarchive. By default it used jinja template from archive name |
| kibana_home       | `/opt/kibana/{{ kibana_folder }}`                           | Specify Kibana install folder                                                       |

Example Playbook
----------------

```yaml
- hosts: all
  roles:
      - malzew.kibana
```

License
-------

BSD

Author Information
------------------

Andrey Maltsev
