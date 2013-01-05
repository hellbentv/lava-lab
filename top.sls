base:
  '*':
    - sshd
    - lp_users

  'dispatcher':
    - instance_manager
    - nfs
    - adb

  'control, staging, dogfood, fastmodels01, fastmodels02':
    - match: list
    - instance_manager
    - nfs
    - adb
    - lava
