# allows syncing of our ARM model simulators
/opt/arm:
  url.sync_extract:
    - url: http://192.168.1.21/LAVA_HTTP/arm_models.tgz
    - md5sum: af9ae53322e0832f2e326aa88c0de049
    - user: root
    - group: root
    - mode: 755
