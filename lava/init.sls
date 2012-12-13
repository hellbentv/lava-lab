# allows us to keep files in sync with lava instances on hosts
# this assumes a file layout on the server like:
#   /srv/salt/lava/devices/<host>/<instance>/
#           device1.conf, device2.conf, ...
salt://lava/devices/{{ grains['host'] }}:
  lava:
    - sync_devices

{% for inst in grains['lava_instances'] %}
{{ inst }}/etc/lava-dispatcher/urlmappings.txt:
  file.managed:
    - source: salt://lava/urlmappings.txt

{{ inst }}/etc/lava-dispatcher/device-types:
  file.recurse:
    - source: salt://lava/device-types
{% endfor %}
