#!/bin/bash

BASE_CONTAINER_HOST_NAME="mysql-innodb-cluster-vm"
CONTAINER_REPLICATION_COUNT="3"
MYSQL_ROOT_PASS="verySecurePa33w0rd"
MYSQL_ADMIN_USER="clusteradmin"
MYSQL_ADMIN_PASS="superSecretPassword"

echo "Create clusteradmin users inside the mysql server containers"

for ((i = 1 ; i <= ${REPLICATION_COUNT} ; i++));
do
  docker exec -it "${BASE_CONTAINER_HOST_NAME}${index}" mysql -uroot -p${MYSQL_ROOT_PASS} \
  -e "CREATE USER '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';" \
  -e "GRANT ALL privileges ON *.* TO '${MYSQL_ADMIN_USER}'@'%' with grant option;" \
  -e "reset master;"
done

echo "Validate clusteradmin users have been created"
for ((i = 1 ; i <= ${REPLICATION_COUNT} ; i++));
do
  docker exec -it "${BASE_CONTAINER_HOST_NAME}${index}" mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} \
  -e "select @@hostname;" \
  -e "SELECT user from mysql.user where user='${MYSQL_ADMIN_USER}';"
done

echo "Execution complete. Leaving..."