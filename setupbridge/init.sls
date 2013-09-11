networking:
  service:
    - running

/etc/network/interfaces:
  file:
    - managed
    - source: salt://setupbridge/interfaces-{{ grains['id'] }}

