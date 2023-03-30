{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as freeradius with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set script_name = 'sync_letsencrypt_to_freeradius.sh' %}

freeradius-certificates-letsencrypt-sync-script:
  file.managed:
    - name: /usr/local/bin/{{ script_name }}
    - source: salt://freeradius/files/sync_script.sh.jinja
    - mode: '0744'
    - makedirs: True
    - template: jinja
    - require:
      - file: freeradius-letsencrypt-dir
    - context:
        user: {{ freeradius.user }}
        group: {{ freeradius.group }}
        target: {{ freeradius.config_dir }}/certs/letsencrypt
        sources:
{%- for domain in freeradius.certificates.letsencrypt %}
            - /etc/letsencrypt/live/{{ domain }}/fullchain.pem
            - /etc/letsencrypt/live/{{ domain }}/privkey.pem
{%- endfor %}

freeradius-certificates-letsencrypt-sync-script-run:
  cmd.run:
    - name: /usr/local/bin/{{ script_name }}
    - onchanges:
        - file: freeradius-certificates-letsencrypt-sync-script

freeradius-certificates-letsencrypt-sync-script-cron:
  cron.present:
    - name: /usr/local/bin/{{ script_name }}
    - month: '*'
    - dayweek: '*'
    - minute: {{ freeradius.certificates.cron.minute }}
    - hour: {{ freeradius.certificates.cron.hour }}