base:
  '*':
    - sshd
    - lp_users

  'control,staging,dogfood,fastmodels01,fastmodels02,dispatcher01,hackbox':
    - match: list
    - instance_manager
    - nfs
    - adb
    - lava

  'fastmodels*':
    - match: pcre
    - lava.fastmodels
