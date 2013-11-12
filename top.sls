base:
  '*':
    - sshd

  'homenas':
    - bridge-utils
    - ser2net
    - lava
    - setupbridge
    - adb
    - lp-users
    - qemu
    - tftpd-hpa
    - nfs

  'x1carbon':
    - bridge-utils
    - ser2net
    - tftpd-hpa
    - nfs
    - lava

  'hasdell':
    - lava
    - ser2net
    - bridge-utils
    - setupbridge
    - adb
    - lp-users
    - qemu
    - tftpd-hpa
    - nfs

  'lavaserver':
    - lava.webinterface

  
