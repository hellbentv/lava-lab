base:
  '*':
    - sshd

  'homenas':
    - bridge-utils
    - ser2net
    - lava
    - setupbridge
    - adb
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
    - qemu
    - tftpd-hpa
    - nfs
    - udev

  'lavaserver':
    - lava.webinterface

  
