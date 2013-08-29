# installs lava coordinator config file (staging)

/etc/lava-coordinator/lava-coordinator.conf:
  file.managed:
    - source: salt://staging-coordinator/lava-coordinator.conf
    - owner: root
    - mode: 644
