nfs_client:
  pkg.installed:
    - name: nfs-common

#/mnt/nas01/val_backup:
#  mount.mounted:
#    - device: 192.168.1.172:/home/raid/linaro/salt-backup
#    - fstype: nfs
#    - mkmnt: True
#    - require:
#      - pkg: nfs-common
