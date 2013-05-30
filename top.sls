base:
  '*':
    - sshd
    - lp_users

  'control,staging,dogfood,fastmodels01,fastmodels02,fastmodels03,fastmodels04,fastmodels05,fastmodels06,fastmodels07,dispatcher01,hackbox':
    - match: list
    - instance_manager
    - nfs
    - adb
    - lava

  'control':
    - lava.munin

  'fastmodels*':
    - match: pcre
    - lava.fastmodels
