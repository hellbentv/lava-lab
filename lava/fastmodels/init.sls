# allows syncing of our ARM model simulators
/opt/arm:
  url.sync_extract:
    - url: http://192.168.1.21/LAVA_HTTP/arm_models/arm_models-2013-01-11.tgz
    - md5sum: c6302051824c1dfcb4f2212afd656b98
    - user: root
    - group: root
    - mode: 755

#install tapctl

#install brctl
bridge-utils:
  pkg:
      - installed

#run the setup.sh script

