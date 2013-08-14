tftpd-hpa:
  pkg:
    - installed
  file.managed:
    {% if grains['id'] == 'staging'%}
    - source: salt://tftpd-hpa/tftpd-hpa-staging
    {% elif grains['id'] == 'multinode'%}
    - source: salt://tftpd-hpa/tftpd-hpa-multinode
    {% elif grains['id'] == 'control'%}
    - source: salt://tftpd-hpa/tftpd-hpa-control
    {% else %}
    - source: salt://tftpd-hpa/tftpd-hpa-production
    {% endif %}
    - name: /etc/default/tftpd-hpa
    - owner: root
    - mode: 600
    - require:
      - pkg: tftpd-hpa
  service.running:
    - enable: True
    - watch:
      - file: /etc/default/tftpd-hpa
      - pkg: tftpd-hpa
