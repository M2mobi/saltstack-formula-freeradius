# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_pkg_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as freeradius with context %}

include:
  - {{ sls_pkg_install }}

freeradius-service:
  service.running:
    - name: radiusd
    - enable: True
    - watch:
      - pkg: freeradius_install
    - require:
      - pkg: freeradius_install
