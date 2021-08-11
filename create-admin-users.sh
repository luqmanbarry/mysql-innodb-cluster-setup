#!/bin/bash

BASE_CONTAINER_HOST_NAME="mysql-vm"
REPLICATION_COUNT="3"
MYSQL_ROOT_PASS="verySecurePa33w0rd"
MYSQL_ADMIN_USER="clusteradmin"
MYSQL_ADMIN_PASS="cluster_admin_password"

echo ""
echo "Create clusteradmin users inside the mysql server containers"
echo ""

for ((index = 1 ; index <= ${REPLICATION_COUNT} ; index++));
do
  echo ""
  echo "Creating user \"${MYSQL_ADMIN_USER}\" on \"${BASE_CONTAINER_HOST_NAME}${index}\""
  echo ""
  docker exec -it "${BASE_CONTAINER_HOST_NAME}${index}" mysql -uroot -p${MYSQL_ROOT_PASS} \
  -e "CREATE USER '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';" \
  -e "GRANT ALL privileges ON *.* TO '${MYSQL_ADMIN_USER}'@'%' with grant option;" \
  -e "reset master;"
  if [ "$?" != "0" ];
  then
    echo ""
    echo "Failed to create user \"${MYSQL_ADMIN_USER}\" on "${BASE_CONTAINER_HOST_NAME}${index}". Exiting.."
    echo ""
    exit 1
  fi
done

echo "Validate clusteradmin users have been created"
for ((index = 1 ; index <= ${REPLICATION_COUNT} ; index++));
do
  docker exec -it "${BASE_CONTAINER_HOST_NAME}${index}" mysql -u${MYSQL_ADMIN_USER} -p${MYSQL_ADMIN_PASS} \
  -e "select @@hostname;" \
  -e "SELECT user from mysql.user where user='${MYSQL_ADMIN_USER}';"
done

echo "Execution complete successfully..."