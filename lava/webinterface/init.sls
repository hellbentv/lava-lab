### this is not pretty but it works

{% if grains['id'] == 'lavaserver' %}
apache2:
  pkg:
    - installed
  service:
    - running
    - watch:
      - file: /etc/apache2/sites-available/production.conf
      - file: /etc/apache2/sites-enabled/002-production.conf

lava:
  service:
    - running
    - watch:
      - file: /srv/lava/instances/production/etc/lava-server/settings.conf

/etc/apache2/sites-available/production.conf:
  file.managed:
    - source: salt://lava/webinterface/apache.conf
    - mode: 644
    - user: root
    - group: root

/etc/apache2/sites-enabled/002-production.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/production.conf

/srv/lava/instances/production/etc/lava-server/settings.conf:
  file.managed:
    - source: salt://lava/webinterface/django.conf
    - mode: 644
    - user: root
    - group: root
{% endif %}


