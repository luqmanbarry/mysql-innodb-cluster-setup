# Setting up MySql InnoDB Cluster with Automatic Failover

**Note:** It is recommended to have an odd number of cluster members(ie: 3,5...)

### Setup the cluster members

1. Create the docker network

`
    docker network create "mysql-cluster-net" --subnet "10.0.0.1/28"

    docker network ls
`

2. Execute the docker-compose file

`
    docker-compose -f docker-compose.dbserver.yaml up --force-recreate

    docker ps -- keep waiting until status shows healthy
`

3. Create admin users into the mysql servers

`
    ./create-admin-users.sh
`

4. Check instance configuration

`
    docker exec -it mysql-vm1 mysqlsh -uroot -p"verySecurePa33w0rd" -S /var/run/mysqld/mysqlx.sock

    \sql    -- Switch to sql mode

    select @@hostname;

    \js     -- Switch to Javascript mode

    dba.checkInstanceConfiguration("clusteradmin@mysql-vm1:3306")

    Enter clusteradmin password when prompted

    Stauts should say error if first setup
`

**Note:** Above step might show errors if first time, just proceed.

      Repeat above step for all the containers

1. Configure all database instances -- Repeate below steps for each container(vm1, vm2, vm3)

`
    docker exec -it mysql-vm1 mysqlsh -uroot -pverySecurePa33w0rd -S/var/run/mysqld/mysqlx.sock

    dba.configureInstance("clusteradmin@mysql-vm1:3306")

    Enter clusteradmin password when prompted

    Answer all prompts with Y

    dba.configureInstance("clusteradmin@mysql-vm2:3306")

    Enter clusteradmin password when prompted

    Answer all prompts with Y

    dba.configureInstance("clusteradmin@mysql-vm3:3306")

    Enter clusteradmin password when prompted

    Answer all prompts with Y

    \q   -- Quit shell prompt

    docker-compose -f docker-compose.dbserver.yaml restart

    docker ps   -- Wait until container status shows healthy

    docker exec -it mysql-vm1 mysqlsh -uroot -pverySecurePa33w0rd -S/var/run/mysqld/mysqlx.sock

    dba.checkInstanceConfiguration("clusteradmin@mysql-vm1:3306")

    Enter clusteradmin password when prompted

    Status should say OK

    dba.checkInstanceConfiguration("clusteradmin@mysql-vm2:3306")

    Enter clusteradmin password when prompted

    Status should say OK

    dba.checkInstanceConfiguration("clusteradmin@mysql-vm3:3306")

    Enter clusteradmin password when prompted

    Status should say OK

    \q  -- Quit shell prompt

`

1. Connect to the master instance as clusteradmin and setup other servers as agents

`
    docker exec -it "mysql-vm1" mysqlsh -uclusteradmin -S/var/run/mysqld/mysqlx.sock

    Enter clusteradmin password when prompted

    var cls = dba.createCluster("myCluster")   

    cls.status()                                       

    cls.describe()                                      

    cls.addInstance("clusteradmin@mysql-vm2:3306");

    Select Clone from the option prompt

    cls.addInstance("clusteradmin@mysql-vm3:3306");

    Select Clone from the option prompt

    \q   -- Quit shell

    docker-compose -f docker-compose.dbserver.yaml restart

`

**Note:** Cluster config changes are persisted at /var/lib/mysql/mysqld-auto.cnf
---

### Bootstrap the router server

1. Bootstrap MySql router server

`
    docker-compose -f docker-compose.dbrouter.yaml up
`

    Once mysql-router container is healthy, logs will show that 6446, 6447 are the R/W, R/O ports respectively.

---

## Cluster Troubleshooting

1. Have Container/VM rejoin the cluster -- container can be anything

`
    docker exec -it "mysql-vm1" mysqlsh -uclusteradmin -S/var/run/mysqld/mysqlx.sock

    var cls = dba.rebootClusterFromCompleteOutage();

    Anser Y to all prompts
    
    cls.status()    -- To check, there should at least one instance with R/W mode
`
---

### Operating the Cluster

`
    Follow this [link](https://severalnines.com/database-blog/mysql-innodb-cluster-80-complete-operation-walk-through-part-two)
`

### Tuning the database for performance

Use the mysqltuner.pl script and provide the required arguments

For help with mysqltunner.pl, run:

`
    ./mysqltuner.pl -h
`



