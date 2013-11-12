tftpd-hpa:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch:
      - file: /etc/default/tftpd-hpa
      - pkg: tftpd-hpa
  file.managed:
    - name: /etc/default/tftpd-hpa
    - owner: root
    - mode: 600
    - require:
      - pkg: tftpd-hpa
    - source: salt://setupbridge/tftpd-hpa

