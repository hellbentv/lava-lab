munin-node:
  pkg:
    - installed
  service:
    - running
    - watch:
      - pkg: munin-node
      - file: /etc/munin/plugins/lava*

/etc/munin/plugins/lava_queue:
  file.managed:
    - source: salt://lava/munin/lava_queue
    - mode: 755
