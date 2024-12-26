pkg install -y expect
# Generate Passowrd Zabbix DB
DBZABBIX_PASSWD=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9@#$%^&*()_+' | head -c 16) && export DBZABBIX_PASSWD && echo $DBZABBIX_PASSWD > /root/db_zabbix_pwd.txt

mysql -u root -e "CREATE DATABASE IF NOT EXISTS zabbix character set utf8mb4 collate utf8mb4_bin"
mysql -u root -e "CREATE USER IF NOT EXISTS zabbix@'localhost' identified by '$DBZABBIX_PASSWD'"
mysql -u root -e "GRANT ALL PRIVILEGES on zabbix.* to zabbix@'localhost'"
mysql -u root -e "SET global log_bin_trust_function_creators = 1"
mysql -u root -e "FLUSH PRIVILEGES"
cp /usr/local/etc/apache24/Includes/phpmyadmin.conf.sample /usr/local/etc/apache24/Includes/phpmyadmin.conf
cd /usr/local/share/zabbix7/server/database/mysql && mysql -u zabbix -p'$DBZABBIX_PASSWD' zabbix < schema.sql
cd /usr/local/share/zabbix7/server/database/mysql && mysql -u zabbix -p'$DBZABBIX_PASSWD' zabbix < images.sql
cd /usr/local/share/zabbix7/server/database/mysql && mysql -u zabbix -p'$DBZABBIX_PASSWD' zabbix < data.sql
cd /usr/local/share/zabbix7/server/database/mysql && mysql -u root -e "set global log_bin_trust_function_creators = 0"
sed -i '' 's%# DBPassword=%DBPassword=$DBZABBIX_PASSWD%g' /usr/local/etc/zabbix7/zabbix_server.conf
echo "Your DB_ZABBIX_PASSWD is written on this file /root/db_zabbix_pwd.txt"
chmod 400 /root/db_zabbix_pwd.txt

# Generate Passowrd Root DB
DB_ROOT_PASSWORD=$(openssl rand -base64 32) && export DB_ROOT_PASSWORD && echo $DB_ROOT_PASSWORD > /root/db_root_pwd.txt

SECURE_MYSQL=$(expect -c "
set timeout 10
set DB_ROOT_PASSWORD "$DB_ROOT_PASSWORD"
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No:\"
send \"y\r\"
expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:\"
send \"2\r\"
expect \"New password:\"
send \"$DB_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$DB_ROOT_PASSWORD\r\"
expect \"Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) :\"
send \"Y\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

# Display the location of the generated root password for MySQL
echo "Your DB_ROOT_PASSWORD is written on this file /root/db_root_pwd.txt"

# No one but root can read this file. Read only permission.
chmod 400 /root/db_root_pwd.txt