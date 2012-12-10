nfs_client:
  pkg.installed:
    - name: nfs-common

/mnt/nas01/val_backup:
  mount.mounted:
    - device: 192.168.1.21:/c/val_backup
    - fstype: nfs
    - mkmnt: True
