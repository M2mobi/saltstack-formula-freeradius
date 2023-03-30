{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_pkg_install = tplroot ~ '.certificates.letsencrypt' %}
{%- from tplroot ~ "/map.jinja" import mapdata as freeradius with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

freeradius-letsencrypt-dir:
  file.directory:
    - name: {{ freeradius.config_dir }}/certs/letsencrypt
    - user: {{ freeradius.user }}
    - group: {{ freeradius.group }}
    - makedirs: True