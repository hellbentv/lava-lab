ia32-libs:
  pkg:
    - installed

/usr/local/bin/adb:
  file.managed:
    - source: salt://adb/adb
    - user: root
    - group: root
    - mode: 755
