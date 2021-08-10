# Setting up MySql InnoDB Cluster with Automatic Failover

1. Create the docker network

`
    docker network create "mysql-cluster-net" --subnet "10.0.0.1/28"

    docker network ls
`

2. Execute the docker-compose file

`
    docker-compose -f docker-compose.dbserver.yaml up --force-recreate
`

3. Create admin users into the mysql servers

`
    ./create-admin-users.sh
`

4. Check instance configuration

`
    docker exec -it "mysql-innodb-cluster-vm1" mysqlsh -uroot -pverySecurePa33w0rd -S/var/run/mysqld/mysqlx.sock

    \sql;

    select @@hostname;

    \js;

    dba.checkInstanceConfiguration("clusteradmin@mysql-innodb-cluster-vm1:3306")

    Enter password when prompted

    Stauts should say error if first setup
`

**Note:** Above step might show errors if first time, just proceed.

      Repeat above step for all the containers

5. Configure all database instances -- Repeate below steps for each container

`
    docker exec -it mysql-innodb-cluster-vm1 mysqlsh -uroot -pverySecurePa33w0rd -S/var/run/mysqld/mysqlx.sock

    Enter password when prompted

    dba.configureInstance("clusteradmin@mysql-innodb-cluster-vm1:3306")

    Answer all prompts with Y

    docker restart "mysql-innodb-cluster-vm1"

    docker exec -it mysql-innodb-cluster-vm1 mysqlsh -uroot -pverySecurePa33w0rd -S/var/run/mysqld/mysqlx.sock

    Enter password when prompted

    dba.checkInstanceConfiguration("clusteradmin@mysql-innodb-cluster-vm1:3306")

    Status should say OK

`

6. Connect to the master instance and setup other servers as agents

`
    docker exec -it "mysql-innodb-cluster-vm1" mysqlsh -uroot -pverySecurePa33w0rd -S/var/run/mysqld/mysqlx.sock

    Enter password when prompted

    var cls = dba.createCluster("mysqlInnodbCluster")   

    cls.status()                                       

    cls.describe()                                      

    cls.addInstance("clusteradmin@mysql-innodb-cluster-vm2:3306");

    Select Clone from the option prompt

    cls.addInstance("clusteradmin@mysql-innodb-cluster-vm3:3306");

    Select Clone from the option prompt

    docker-compose -f docker-compose.dbserver.yaml down

    docker-compose -f docker-compose.dbserver.yaml up

`

7. Bootstrap MySql router server

`
    docker-compose -f docker-compose.dbrouter.yaml up --force-recreate
`




