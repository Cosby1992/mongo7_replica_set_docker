# MongoDB Replica Set Cluster Setup with Keyfile Authentication

This project demonstrates how to set up a MongoDB replica set cluster using Docker Compose with keyfile authentication for enhanced security.

## Prerequisites

- Docker and Docker Compose installed on your system.

## Project Structure

- `docker-compose.yml`: Docker Compose file to define and run MongoDB replica set cluster with three nodes.
- `Dockerfile`: Dockerfile for building MongoDB image with keyfile authentication setup.
- `keyfile`: Directory containing the keyfile for MongoDB authentication.

## MongoDB version compatability
This project currently utilizes MongoDB version 7. However, it is designed to be compatible with earlier versions, extending back to MongoDB 5. If you need to use a different MongoDB version, you can easily accomplish this by modifying the base image in the Dockerfile. Simply update the base image to the desired MongoDB version, and the setup should remain functional.

## Usage

1. Clone this repository to your local machine:

   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory:

   ```bash
   cd mongodb-replica-set-keyfile-auth
   ```

3. Modify the content of `example.env` to reflect your desired environment variables. 
Replace placeholder values with your actual configuration.
Rename the file from `example.env` to `.env`. 
This step is crucial as Docker Compose automatically looks for a file named .env to load environment variables.

4. Set up the MongoDB replica set cluster by running Docker Compose:

   ```bash
   docker-compose up --build
   ```

   This command will build the Docker images and start the MongoDB nodes for the replica set cluster (`mongo1`, `mongo2`, `mongo3`).
   They will not be connected to the replica set before it has been configured.

## Initiating the Replica Set

Before you can use the MongoDB replica set, you need to initiate it and configure the replica set members. Here's how you can do it using `mongosh`:

1. Connect to one of the MongoDB instances in the cluster using `mongosh`. For example:

   ```bash
   mongosh "mongodb://<username>:<password>@localhost:27017/admin"
   ```

   Replace `<username>` and `<password>` with your MongoDB credentials.

   **TIP:** too keep you password hidden in logs, you can use one of these two approaches instead:

    - `mongosh -u admin -p` which will prompt for password
    - `mongosh --host <hostname>:<port> -u admin -p` which will also prompt for password

Replace `<hostname>` and `<port>` with the hostname and port of your MongoDB instance.

2. Once connected, initiate the replica set using the `rs.initiate()` method. For example:

   ```js
   rs.initiate({
     _id: "ha_rs",
     members: [
       { _id: 0, host: "mongo1:27017" },
       { _id: 1, host: "mongo2:27017" },
       { _id: 2, host: "mongo3:27017" },
     ],
   });
   ```

   This command initiates the replica set with the name `ha_rs` and specifies the members of the replica set, including their IDs and hostnames with port numbers.

3. After initiating the replica set, you can check its status using the `rs.status()` command to ensure that it's successfully configured and all members are in the `PRIMARY` or `SECONDARY` state.

By following these steps, you can initiate the MongoDB replica set and configure its members for high availability and data redundancy.

## Initiating a MongoDB Replica Set with Priorities
When initiating a MongoDB replica set using the rs.initiate() command, you can specify priorities for the members to influence their eligibility for becoming the primary in case of a failover.

Assigning priorities allows you to fine-tune the behavior of your replica set based on the roles and capabilities of each member. By specifying priorities, you can ensure that certain nodes are more likely to become primaries, thereby influencing the distribution of workload and optimizing performance according to your specific requirements.

1. Once connected, initiate the replica set with the first member and specify priorities for each member using the priority field. For example:

```js
rs.initiate(
  {
    _id: "ha_rs",
    members: [
      { _id: 0, host: "mongo1:27017", priority: 3 },
      { _id: 1, host: "mongo2:27017", priority: 2 },
      { _id: 2, host: "mongo3:27017", priority: 1 }
    ]
  }
)
```
In this example, mongo1 is configured with a priority of 3, indicating that it should be preferred as the primary node over mongo2 and mongo3, which have a priority of 2 and 1 respectively.

After initiating the replica set with priorities, you can verify the replica set status using the rs.status() command to ensure that the configuration is as expected.

By specifying priorities during replica set initialization, you gain greater control over the election process and the distribution of workload within your MongoDB cluster. This allows you to optimize performance, improve fault tolerance, and tailor the replica set configuration to meet the specific demands of your application.


## Configuration

- The `docker-compose.yml` file defines three MongoDB nodes (`mongo1`, `mongo2`, `mongo3`) with port mappings for accessing MongoDB instances.
- The `Dockerfile` sets up the MongoDB image with keyfile authentication. It copies the keyfile into the container and sets the necessary permissions.

## Environment Variables

- `MONGO_INITDB_ROOT_USERNAME`: Root username for MongoDB initialization.
- `MONGO_INITDB_ROOT_PASSWORD`: Root password for MongoDB initialization.

## Keyfile Authentication

- The keyfile for MongoDB authentication is stored in the `keyfile` directory.
- It is copied into the Docker container during the image build process and set with restrictive permissions (`600`) for enhanced security.

## Replica Set Configuration

- The MongoDB replica set is configured with the name `ha_rs`.
- Each MongoDB node is configured with the replica set name and keyfile for authentication.

## Networking

- The MongoDB nodes are connected to a bridge network named `mongo_ha_rs_network` for internal communication.

## Maintenance

- To stop the MongoDB replica set cluster, use:

  ```bash
  docker-compose down
  ```

- To remove all volumes associated with the cluster, use:

  ```bash
  docker-compose down -v
  ```

## Useful MongoDB Replica Set Commands/Functions

### 1. `rs.initiate(config)`

**Description:** Initiates a new replica set with the specified configuration.

**Example:**
```js
rs.initiate(
  {
    _id: "ha_rs",
    members: [
      { _id: 0, host: "mongo1:27017" },
      { _id: 1, host: "mongo2:27017" },
      { _id: 2, host: "mongo3:27017" }
    ]
  }
)
```

### 2. `rs.add(hostname:port)` or `rs.add(member)`

**Description:** Adds a new member to the replica set.

**Example:**
```js
rs.add("mongo4:27017")
```
or
```js
rs.add({_id: 3, "mongo4:27017", priority: 1 })
```

### 3. `rs.remove(hostname:port)`

**Description:** Removes a member from the replica set.

**Example:**
```js
rs.remove("mongo3:27017")
```

### 4. `rs.reconfig(config)`

**Description:** Reconfigures the replica set with the specified configuration.

**Example:**

```js
rs.reconfig(
  {
    _id: "ha_rs",
    members: [
      { _id: 0, host: "mongo1:27017" },
      { _id: 1, host: "mongo2:27017" }
    ]
  }
)
```

**TIP:** This can be used in combination with `rs.conf()` to easily modify existing configurations. 

**Example:**

```js
cfg = rs.conf()

cfg.members[0].priority = 2

rs.reconfig(cfg)
```


### 5. `rs.stepDown()`

**Description:** Forces the current primary to step down and initiate an election.

**Example:**

```js
rs.stepDown()
```

### 6. `rs.freeze(seconds)`

**Description:** Prevents the current primary from becoming primary again for the specified number of seconds.

**Example:**

```js
rs.freeze(60)
```

### 7. `rs.secondaryOk()`

**Description:** Allows read operations on secondary nodes.

**Example:**

```js
rs.secondaryOk()
```

**OBS:** You might not want to set this as a global setting. If it is just needed on a single query or command. It can be set for just the one query:

```js
db.test.find({}).readPref('secondary');
```

### 8. `rs.printReplicationInfo()`

**Description:** Prints detailed replication information for each member of the replica set.

**Example:**

```js
rs.printReplicationInfo()
```

### 9. `rs.isMaster()`

**Description:** Checks if the current node is the primary or secondary.

**Example:**

```js
rs.isMaster()
```

### 10. `rs.conf()`

**Description:** Retrieves the current replica set configuration.

**Example:**

```js
rs.conf()
```

### 11. `rs.help()`

**Description:** Displays help for replica set commands/functions.

**Example:**

```js
rs.help()
```

## References and Further Reading

### MongoDB Official Documentation

- [MongoDB Replica Set Documentation](https://docs.mongodb.com/manual/replication/)
- [MongoDB Security Documentation](https://docs.mongodb.com/manual/security/)
- [MongoDB Docker Hub Repository](https://hub.docker.com/_/mongo)

### Blog Posts and Tutorials

- [Replica Set Deployment Tutorials](https://www.mongodb.com/docs/manual/administration/replica-set-deployment/)
- [Deploy Replica Set With Keyfile Authentication](https://www.mongodb.com/docs/manual/tutorial/deploy-replica-set-with-keyfile-access-control/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Best Practices for Docker Compose with MongoDB](https://docs.docker.com/samples/mongodb/)

### Community Resources

- [MongoDB Community Forums](https://community.mongodb.com/)
- [Docker Community Forums](https://forums.docker.com/)

## License

This project is licensed under the [MIT License](LICENSE).
