base:
  '*':
    - sshd
    - lp_users

  'dispatcher':
    - instance_manager
    - nfs
    - adb
