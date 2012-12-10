instance-manager:
  user.present:
    - fullname: LAVA Instance Manager
    - shell: /bin/bash
    - home: True
    - password: "$6$deeghiuc$XR0x84I.p6/JEMUuZjRLKM6Q7NWD9YsdjwT/qeR9zuGLKNBJRPRKpX7malPM59lV4Cqi2DDsTDEQ3R/ZL2.im/"
    - groups:
      - sudo

  file.managed:
      - source: salt://instance_manager/sudoer_file
      - name: /etc/sudoers.d/instance_manager
      - user: root
      - group: root
      - mode: 440

lp:lava-deployment-tool:
  bzr.latest:
    - target: /home/instance-manager/lava-deployment-tool
    - runas: instance-manager
    - require:
      - user: instance-manager
