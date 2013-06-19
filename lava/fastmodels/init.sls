# allows syncing of our ARM model simulators
/opt/arm:
  url.sync_extract:
    - url: http://192.168.1.21/LAVA_HTTP/arm_models/arm_models-2013-01-11.tgz
    - md5sum: c6302051824c1dfcb4f2212afd656b98
    - user: root
    - group: root
    - mode: 755

#install tapctrl
/usr/sbin/tapctrl:
  file.symlink:
  - target: /opt/arm/RTSMv8_VE/scripts/tapctrl
  - require:
    - url: /opt/arm/RTSMv8_VE/scripts/tapctrl

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
start FMNetwork:
  cmd.run:
    - user: root
    - name: "update-rc.d FMNetwork defaults"
    - require:
      - url: /etc/init.d/FMNetwork
