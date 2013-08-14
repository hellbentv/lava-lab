{% if grains['id'] == 'staging'%}
tftpd-hpa:
  pkg:
    - installed
  file.managed:
    - source: salt://tftpd-hpa/tftpd-hpa-staging
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
{% endif %}
{% if grains['id'] != 'staging'%}
tftpd-hpa:
  pkg:
    - installed
  file.managed:
    - source: salt://tftpd-hpa/tftpd-hpa-production
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
{% endif %}
