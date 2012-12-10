bzr:
  pkg:
    - installed

lp:~doanac/+junk/linaro-its-tools:
  bzr.latest:
    - target: /usr/local/linaro-its-tools

lp-users:
  group.present:
    - gid: 1001

/etc/lp-manage-local.conf:
  file.managed:
      - source: salt://lp_users/lp-manage-local.conf-{{ grains['host'] }}
      - user: root
      - group: root
      - mode: 444

# sync users via cron hourly
/usr/local/linaro-its-tools/lp-manage-local > /tmp/lp-manage-local.log:
  cron:
    - present
    - user: root
    - minute: 21
