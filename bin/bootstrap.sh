#!/bin/bash
mysql -u root -ppassword icinga2_web -e "insert into icinga2_web.icingaweb_user VALUES ('icingaadmin', 1, '\$1\$usghGMNC\$h8Lk.QA8OUSvEkz45o.0u1', NULL, NULL);"
