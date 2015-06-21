#!/bin/bash
mysql -u root -ppassword icinga2_data < /usr/share/icinga2-ido-mysql/schema/mysql.sql
mysql -u root -ppassword icinga2_web < /usr/share/icingaweb2/etc/schema/mysql.schema.sql
mysql -u root -ppassword icinga2_web -e "insert into icinga2_web.icingaweb_user VALUES ('icingaadmin', 1, '\$1\$usghGMNC\$h8Lk.QA8OUSvEkz45o.0u1', NULL, NULL);"
