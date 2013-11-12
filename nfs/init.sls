nfs-kernel-server:
  pkg:
    - latest
  service.running:
    - enable: True
    - watch:
      - file: exports
      - pkg: nfs-kernel-server

rpcbind:
  pkg:
    - latest

exports:
  file.managed:
    {% if grains['id'] == 'homenas'%}
    - source: salt://nfs/nfs-exports-homenas
    {% else %}
    - source: salt://nfs/nfs-exports
    {% endif %}
    - name: /etc/exports
    - owner: root
    - group: root
    - mode: 644
    - require:
      - pkg: nfs-kernel-server

update_exports:
  cmd.run:
    - name: exportfs -ra
    - require:
      - pkg: nfs-kernel-server
    - watch:
      - file: exports

nfs_client:
  pkg.installed:
    - name: nfs-common

