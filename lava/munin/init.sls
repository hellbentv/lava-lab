/etc/munin/plugins/lava_queue:
  file.managed:
    - source: salt://lava/munin/lava_queue
    - mode: 755
