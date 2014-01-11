base:
  '*':
    - sshd

  'nuc1':
    - lava
    - ser2net
    - bridge-utils
    - setupbridge
    - adb
    - qemu
    - tftpd-hpa
    - nfs

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

  
