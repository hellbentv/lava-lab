base:
  '*':
    - sshd
    - lp_users

  'dispatcher':
    - instance_manager
    - nfs
    - adb

  'control':
    - instance_manager
    - nfs
    - adb
    - lava

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

  'staging':
    - instance_manager
    - nfs
    - adb
    - lava
