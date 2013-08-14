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
      {% if grains['id'] == 'staging'%}
      - file: /srv/lava/instances/staging/etc/lava-server/settings.conf
      {% elif grains['id'] == 'control'%}
      - file: /srv/lava/instances/production/etc/lava-server/settings.conf
      {% endif %}

/etc/apache2/sites-available/validation.linaro.org.conf:
  file.managed:
    - source: salt://lava/webinterface/apache.conf
    - mode: 644
    - user: root
    - group: root

/etc/apache2/sites-enabled/002-validation.linaro.org.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/validation.linaro.org.conf

/srv/lava/instances/staging/etc/lava-server/settings.conf:
  file.managed:
    {% if grains['id'] == 'staging'%}
    - source: salt://lava/webinterface/django-staging.conf
    {% elif grains['id'] == 'control'%}
    - source: salt://lava/webinterface/django.conf
    {% endif %}
    - mode: 644
    - user: root
    - group: root
