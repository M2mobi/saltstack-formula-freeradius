# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - .package
  - .service
  - .config

groups:
  group.present:
    - name: radiusd
