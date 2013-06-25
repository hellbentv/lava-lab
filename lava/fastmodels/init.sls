# allows syncing of our ARM model simulators
/opt/arm:
  url.sync_extract:
    - url: http://192.168.1.21/LAVA_HTTP/arm_models/arm_models-2013-06-25.tgz
    - md5sum: a5e7c5b5571e2e12975c41401e78f2f3
    - user: root
    - group: root
    - mode: 755
