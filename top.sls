base:
  '*':
    - sshd
    - lp_users
    - nagios

  'control,staging,fastmodels01,fastmodels02,fastmodels03,fastmodels04,fastmodels05,fastmodels06,dispatcher01,dispatcher02,hackbox,multinode,staging01,playgroundmaster,playgroundworker01':
    - match: list
    - instance_manager
    - nfs
    - adb
    - openbsd-inetd
    - tftpd-hpa
    - lava

  'control':
    - lava.webinterface
    - lava.munin

  'staging':
    - lava.webinterface

  'staging*':
    - lava.fastmodels
    - staging-coordinator

  'fastmodels*':
    - match: pcre
    - lava.fastmodels
