base:
  '*':
    - sshd
    - lp_users
    - nagios

  'lavaserver, homecloud, homenas, lava-bbblack-dispatcher01, hasdell':
    - match: list
    - instance_manager
    - nfs
    - adb
    - openbsd-inetd
    - tftpd-hpa
    - lava
    - qemu

  'homenas':
    - bridge-utils
    - ser2net
    - lava
    - setupbridge

  'hasdell':
    - lava
    - ser2net
    - bridge-utils
    - setupbridge

  'lava-bbblack-dispatcher01':
    - ser2net
    - lava
      
  'lavaserver':
    - lava.webinterface
    - lava.munin

  'lavaserver, homenas':
    - match: list
    - lava.production-coordinator

