base:
  '*':
    - sshd
    - lp_users
    - nagios

  'lavaserver, homecloud, homenas':
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
      
  'lavaserver':
    - lava.webinterface
    - lava.munin

  'lavaserver, homenas':
    - match: list
    - lava.production-coordinator

