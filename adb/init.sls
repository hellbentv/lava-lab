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

# platform tools requires an interactive UI, so we just keep a tarball
# locally and explode it
/usr/local/android-sdk-linux/platform-tools:
  url.sync_extract:
    - url: http://192.168.1.21/LAVA_HTTP/android-binaries/platform-tools.tar.gz
    - md5sum: 61a84eabd21643d6dd8c387f7ad1180c
    - require:
      - url: /usr/local/android-sdk-linux
      - pkg: openjdk-6-jdk

/usr/local/bin/adb:
  file.symlink:
    - target: /usr/local/android-sdk-linux/platform-tools/adb
    - require:
      - url: /usr/local/android-sdk-linux/platform-tools

/usr/local/bin/monkeyrunner:
  file.symlink:
    - target: /usr/local/android-sdk-linux/tools/monkeyrunner
    - require:
      - url: /usr/local/android-sdk-linux
