apache2:
  pkg:
    - installed
  service:
    - running
    - watch:
      - file: /etc/apache2/sites-available/validation.linaro.org.conf
      - file: /etc/apache2/sites-enabled/002-validation.linaro.org.conf

lava:
  service:
    - running
    - watch:
      - file: /srv/lava/instances/production/etc/lava-server/settings.conf

/etc/apache2/sites-available/validation.linaro.org.conf:
  file.managed:
    - source: salt://lava/webinterface/apache.conf
    - mode: 644
    - user: root
    - group: root

/etc/apache2/sites-enabled/002-validation.linaro.org.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/validation.linaro.org.conf

{% if salt['lava.list_instances']() == 'staging'%}
/srv/lava/instances/production/etc/lava-server/settings.conf:
  file.managed:
    - source: salt://lava/webinterface/django-staging.conf
    - mode: 644
    - user: root
    - group: root
{% endif %}

{% if salt['lava.list_instances']() != 'staging'%}
/srv/lava/instances/production/etc/lava-server/settings.conf:
  file.managed:
    - source: salt://lava/webinterface/django.conf
    - mode: 644
    - user: root
    - group: root
{% endif %}
