base:
  '*':
    - sshd
    - lp_users

  'dispatcher':
    - instance_manager
    - nfs
    - adb

  'fastmodels*':
    - instance_manager
    - nfs
    - adb
    - lava

  'dogfood':
    - instance_manager
    - nfs
    - adb
    - lava
