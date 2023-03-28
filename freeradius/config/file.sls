# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_pkg_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as freeradius with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_pkg_install }}

freeradius-clients-config:
  file.managed:
    - name: {{ freeradius.config_dir }}/clients.conf
    - source: salt://freeradius/files/clients.conf
    - mode: '0644'
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        clients: {{ freeradius.clients | json }}

freeradius-auth-config:
  file.managed:
    - name: {{ freeradius.config_dir }}/mods-config/files/authorize
    - mode: '0644'
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True
    - require:
      - pkg: freeradius_install
    - contents: |
        DEFAULT Auth-Type := rest

freeradius-letsencrypt-dir:
  file.directory:
    - name: {{ freeradius.config_dir }}/certs/letsencrypt
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True


{% if 'mods' in freeradius %}
{% for name,mod in freeradius.mods.items() %}
freeradius-mod-{{ name }}-config:
  file.managed:
    - name: {{ freeradius.config_dir }}/mods-available/{{ name }}
    - source: salt://freeradius/files/mods-available/{{ name }}
    - mode: '0644'
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        mod: {{ mod }}

{% if mod.get('enabled', False) == True  %}
freeradius-mod-{{ name }}-config-enable:
  file.symlink:
    - name: {{ freeradius.config_dir }}/mods-enabled/{{ name }}
    - target: {{ freeradius.config_dir }}/mods-available/{{ name }}
    - mode: '0644'
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True
    - require:
      - freeradius-mod-{{ name }}-config
{% else %}
freeradius-mod-{{ name }}-config-disable:
  file.remove:
    - name: {{ freeradius.config_dir }}/mods-enabled/{{ name }}
    - require:
      - freeradius-mod-{{ name }}-config
{% endif %}
{% endfor %}
{% endif %}

{% if 'sites' in freeradius %}
{% for name,site in freeradius.sites.items() %}
freeradius-site-{{ name }}-config:
  file.managed:
    - name: {{ freeradius.config_dir }}/sites-available/{{ name }}
    - source: salt://freeradius/files/sites-available/{{ name }}
    - mode: '0644'
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        site: {{ site }}

{% if site.get('enabled', False) == True  %}
freeradius-site-{{ name }}-config-enable:
  file.symlink:
    - name: {{ freeradius.config_dir }}/sites-enabled/{{ name }}
    - target: {{ freeradius.config_dir }}/sites-available/{{ name }}
    - mode: '0644'
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True
    - require:
      - freeradius-site-{{ name }}-config
{% else %}
freeradius-site-{{ name }}-config-disable:
  file.remove:
    - name: {{ freeradius.config_dir }}/sites-enabled/{{ name }}
    - require:
      - freeradius-site-{{ name }}-config
{% endif %}
{% endfor %}
{% endif %}
