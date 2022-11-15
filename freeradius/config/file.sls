# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_pkg_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as freeradius with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set config_dir = "/etc/raddb" %}
{%- set radius_grp = "radiusd" %}

include:
  - {{ sls_pkg_install }}

freeradius-clients-config:
  file.managed:
    - name: {{ config_dir }}/clients.conf
    - source: salt://freeradius/files/clients.conf
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        freeradius: {{ freeradius | json }}

freeradius-rlm_rest-config:
  file.managed:
    - name: {{ config_dir }}/mods-available/rest
    - source: salt://freeradius/files/mods-available/rest
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        freeradius: {{ freeradius | json }}

freeradius-default-site-config:
  file.managed:
    - name: {{ config_dir }}/sites-available/default
    - source: salt://freeradius/files/sites-available/default
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        freeradius: {{ freeradius | json }}

freeradius-inner-tunnel-config:
  file.managed:
    - name: {{ config_dir }}/sites-available/inner-tunnel
    - source: salt://freeradius/files/sites-available/inner-tunnel
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        freeradius: {{ freeradius | json }}

freeradius-auth-config:
  file.managed:
    - name: {{ config_dir }}/mods-config/files/authorize
    - source: salt://freeradius/files/mods-config/files/authorize
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - pkg: freeradius_install
    - context:
        freeradius: {{ freeradius | json }}

freeradius-enable-default-site:
  file.symlink:
    - name: {{ config_dir }}/sites-enabled/default
    - target: {{ config_dir }}/sites-available/default
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - freeradius-default-site-config
    - context:
        freeradius: {{ freeradius | json }}

freeradius-enable-inner-tunnel-site:
  file.symlink:
    - name: {{ config_dir }}/sites-enabled/inner-tunnel
    - target: {{ config_dir }}/sites-available/inner-tunnel
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - freeradius-inner-tunnel-config
    - context:
        freeradius: {{ freeradius | json }}

freeradius-enable-rlm_rest-module:
  file.symlink:
    - name: {{ config_dir }}/mods-enabled/rest
    - target: {{ config_dir }}/mods-available/rest
    - mode: 644
    - user: root
    - group: {{ radius_grp }}
    - makedirs: True
    - template: jinja
    - require:
      - freeradius-rlm_rest-config
    - context:
        freeradius: {{ freeradius | json }}
