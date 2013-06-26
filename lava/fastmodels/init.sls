# allows syncing of our ARM model simulators
/opt/arm:
  url.sync_extract:
    - url: http://192.168.1.21/LAVA_HTTP/arm_models/arm_models-2013-06-25.tgz
    - md5sum: a5e7c5b5571e2e12975c41401e78f2f3
    - user: root
    - group: root
    - mode: 755

#install tapctrl
/usr/sbin/tapctrl:
  file.symlink:
  - target: /opt/arm/RTSMv8_VE/scripts/tapctrl
  - require:
    - url: /opt/arm

#install brctl
bridge-utils:
  pkg:
    - installed

#copy lava/fastmodels/FMNetwork script
/etc/init.d/FMNetwork:
  file.managed:
    - source: salt://lava/fastmodels/FMNetwork
    - mode: 0755
    - user: root
    - group: root

#start the FMNetwork script:
start_FMNetwork:
  service:
    - running
    - enable: True
    - name: FMNetwork
  require:
    - file: /etc/init.d/FMNetwork
    - url: /opt/arm
