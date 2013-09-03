base:
  '*':
    - sshd
    - lp_users
    - nagios

  'control,fastmodels01,fastmodels02,fastmodels03,fastmodels04,fastmodels05,fastmodels06,dispatcher01,dispatcher02,hackbox,multinode,playgroundmaster,playgroundworker01,staging,staging01':
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

  'control,fastmodels01,fastmodels02,fastmodels03,fastmodels04,fastmodels05,fastmodels06,dispatcher01,dispatcher02':
    - lava.production-coordinator

  'fastmodels*':
    - match: pcre
    - lava.fastmodels

  'staging':
    - lava.webinterface

  'staging*':
    - lava.fastmodels
    - lava.staging-coordinator
