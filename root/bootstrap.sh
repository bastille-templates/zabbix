pkg install -y expect
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