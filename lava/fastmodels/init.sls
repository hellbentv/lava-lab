# allows syncing of our ARM model simulators
/opt/arm:
  url.sync_extract:
    - url: http://192.168.1.21/LAVA_HTTP/arm_models/arm_models-2013-01-11.tgz
    - md5sum: 8871d151ef2f0f9ef9aafe3fcf061c1f
    - user: root
    - group: root
    - mode: 755
