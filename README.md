```
mysql -u root -p icingaweb2 < /usr/share/icingaweb2/etc/schema/mysql.schema.sql
mkdir /etc/icingaweb2/modules/monitoring
chmod 0777 /etc/icingaweb2/modules/monitoring/
```

```
insert into icingaweb_user VALUES ('icingaadmin', 1, '$1$usghGMNC$h8Lk.QA8OUSvEkz45o.0u1', NULL, NULL);
```
