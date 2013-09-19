base:
  '*':
    - sshd
    - lp_users
    - nagios

  'lavaserver, homecloud, homenas, lava-bbblack-dispatcher01':
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

  'lava-bbblack-dispatcher01':
    - ser2net
    - lava
      
  'lavaserver':
    - lava.webinterface
    - lava.munin

  'lavaserver, homenas':
    - match: list
    - lava.production-coordinator

