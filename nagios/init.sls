# installs some packages and creates nagios ssh authorized_keys for nagios checks

nagios:
  user.present:
    - fullname: Nagios Checks User
    - shell: /bin/bash
    - home: /home/nagios
    - password: "thisisnotapasswordhash"

nagios3:
  pkg:
    - installed

/home/nagios/.ssh/:
  file.directory:
    - user: nagios
    - group: nagios
    - mode: 700

/home/nagios/.ssh/authorized_keys:
  file.managed:
    - source: salt://nagios/authorized_keys
    - owner: nagios
    - mode: 600

nagios-plugins-basic:
  pkg:
    - installed

nagios-plugins-standard:
  pkg:
    - installed

nagios-plugins-extra:
  pkg:
    - installed
