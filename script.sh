#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# defaults
MYSQL_VERSION="5.7.12"
MYSQL_ROOT_PASSWORD="test"
MYSQL_CREATE_DB=

# arguments
for i in "$@"; do
  case $i in
    --version=*)
      MYSQL_VERSION="${i#*=}"
      ;;
    --rootpw=*)
      MYSQL_ROOT_PASSWORD="${i#*=}"
      ;;
    --createdb=*)
      MYSQL_CREATE_DB="${i#*=}"
      ;;
    *)
      echo "Unknown argument '$i'"
      exit 1  
      ;;
  esac
done

echo "Installing mysql $MYSQL_VERSION..."

# mysql common
apt-get update
apt-get -y install libaio1 libnuma1 apparmor libmecab2 psmisc
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_$MYSQL_VERSION-1ubuntu14.04_amd64.deb
dpkg -i mysql-common_$MYSQL_VERSION-1ubuntu14.04_amd64.deb

# mysql client
echo "Downloading mysql-community-client..."
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_$MYSQL_VERSION-1ubuntu14.04_amd64.deb
dpkg -i mysql-community-client_$MYSQL_VERSION-1ubuntu14.04_amd64.deb

# mysql client #2
echo "Downloading mysql-client..."
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-client_$MYSQL_VERSION-1ubuntu14.04_amd64.deb
dpkg -i mysql-client_$MYSQL_VERSION-1ubuntu14.04_amd64.deb

# mysql server
echo "Downloading mysql-community-server..."
wget --no-verbose https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server_$MYSQL_VERSION-1ubuntu14.04_amd64.deb
echo "mysql-community-server  mysql-community-server/re-root-pass     password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/root-pass        password	$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-community-server  mysql-community-server/remove-data-dir  boolean true"  | sudo debconf-set-selections
dpkg -i mysql-community-server_$MYSQL_VERSION-1ubuntu14.04_amd64.deb

# by default mysql only allows localhost (not via port forward)
echo "DELETE FROM mysql.user WHERE NOT Host = 'localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "UPDATE mysql.user SET Host='%' where Host='localhost'" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "GRANT ALL PRIVILEGES ON *.* TO root@localhost" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "FLUSH PRIVILEGES" | mysql -u root -p$MYSQL_ROOT_PASSWORD

# port forwards only work to a real ip, not localhost
sed -i "s/= 127.0.0.1/= 0.0.0.0/" /etc/mysql/my.cnf

service mysql restart

# create a database?
if [ ! -z "$MYSQL_CREATE_DB" ]; then
  echo "Creating database $MYSQL_CREATE_DB..."
  echo "CREATE DATABASE $MYSQL_CREATE_DB" | mysql -u root -p$MYSQL_ROOT_PASSWORD
fi

echo "Installed mysql $MYSQL_VERSION"
