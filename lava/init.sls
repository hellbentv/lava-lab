# allows us to keep files in sync with lava instances on hosts
# this assumes a file layout on the server like:
#   /srv/salt/lava/devices/<host>/<instance>/
#           device1.conf, device2.conf, ...
salt://lava/devices/{{ grains['id'] }}:
  lava:
    - sync_devices

{% for inst in salt['lava.list_instances']() %}
{{ inst }}/etc/lava-dispatcher/urlmappings.txt:
  file.managed:
    - source: salt://lava/urlmappings.txt

{{ inst }}/etc/lava-dispatcher/device-types:
  file.recurse:
    - source: salt://lava/device-types
    - clean: True
    - include_empty: True
{% endfor %}

/usr/local/lab-scripts:
  file.recurse:
    - source: salt://lava/lab-scripts
    - file_mode: 755

/root/.ssh/id_rsa:
  file.managed:
    - source: http://192.168.1.21/LAVA_HTTP/linaro-lava-key/id_rsa
    - source_hash: md5=900b277c676360fcfbd2cc10edc5aab7
    - owner: root
    - mode: 600

/root/.ssh/known_hosts:
  file.managed:
    - source: salt://lava/known_hosts
    - owner: root
    - mode: 600

ipmitool:
  pkg:
    - installed
