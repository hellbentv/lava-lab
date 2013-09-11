ia32-libs:
  pkg:
    - installed

openjdk-6-jdk:
  pkg:
    - installed

/usr/local/android-sdk-linux:
  url.sync_extract:
    - url: http://dl.google.com/android/android-sdk_r21.0.1-linux.tgz
    - md5sum: eaa5a8d76d692d1d027f2bbcee019644
    - mode: 0755
    - require:
      - pkg: ia32-libs

  # the download from google doesn't have "root" owning the files
  file.directory:
    - user: root
    - group: root
    - recurse:
      - user
      - group
    - require:
      - url: /usr/local/android-sdk-linux

# platform tools requires an interactive UI, so we just keep a tarball
# locally and explode it
/usr/local/android-sdk-linux/platform-tools:
  url.sync_extract:
    - url: file:///home/platform-tools.tar.gz
    - md5sum: a50252db272df994292590e19c9da839
    - mode: 0755
    - require:
      - url: /usr/local/android-sdk-linux
      - pkg: openjdk-6-jdk

{% if grains['id'] in ['dispatcher01'] %}
# systems with an sdmux require a patched version of adb. see:
# https://android-review.googlesource.com/#/c/50011/
/usr/local/bin/adb:
  file.managed:
    - source: salt://adb/adb-patched
    - mode: 0755
    - user: root
    - group: root

{% else %}
/usr/local/bin/adb:
  file.symlink:
    - target: /usr/local/android-sdk-linux/platform-tools/adb
    - require:
      - url: /usr/local/android-sdk-linux/platform-tools
{% endif %}

/usr/local/bin/monkeyrunner:
  file.symlink:
    - target: /usr/local/android-sdk-linux/tools/monkeyrunner
    - require:
      - url: /usr/local/android-sdk-linux
