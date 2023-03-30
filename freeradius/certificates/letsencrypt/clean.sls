{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_cert_clean = tplroot ~ '.certificates.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as freeradius with context %}

include:
  - {{ sls_cert_clean }}

freeradius-certdir-absent:
  file.absent:
    - name: {{ freeradius.config_dir }}/certs/letsencrypt
    - require:
      - sls: {{ sls_cert_clean }}

freeradius-certificates-letsencrypt-sync-script-clean:
  file.absent:
    - name: /usr/local/bin/sync_letsencrypt_to_freeradius.sh

freeradius-certificates-letsencrypt-sync-script-cron:
  cron.absent