# USE startx db-tools with docker

You can use startx db-tools within a container by using our public 
[official sxapi docker image](https://hub.docker.com/r/startx/db-tools/)


## Want to try ?

To try this application before working on it, the easiest way 
is to use the container version. Follow theses steps to run
a sxapi application within the next couple of minutes. 
(You can skip the first step if you already have [docker](https://www.docker.com)
installed and running)

### 1. Install and start docker

Theses command are for a Red Hat Linux like
environement (Fedora, CentOS, RHEL, Suse). Please adapt `yum` command to the 
```apt-get``` equivalent if you are using a Debian like system (Ubuntu, Debian)

```bash
sudo yum install -y docker
sudo service docker start
```
For more information on how to install and execute a docker runtime, please see
the [official docker installation guide](https://docs.docker.com/engine/installation/)
After installation, pay attention to your user authorisation. Your current user
must interact with the docker daemon.

### 2. Get the sxapi container image

Use docker command to get db-tools container image from the docker hub registry. 
This will update your local docker image cache.

```bash
docker pull startx/db-tools:latest


### 3. Create your database init files 

Create the following file structure

```bash
mkdir mounts
mkdir mounts/mysql-dump
touch mounts/mysql-dump/schema.sql
touch mounts/mysql-dump/data.sql
mkdir mounts/couchbase-dump
touch mounts/couchbase-dump/data.json
```

Example for schema.sql
```sql
DROP TABLE IF EXISTS `app`;
CREATE TABLE `app` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(128) NOT NULL,
  `val` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `key` (`key`),
  KEY `val` (`val`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
```

Example for data.sql
```sql
SET names 'utf8';
LOCK TABLES `app` WRITE;
INSERT INTO `app` VALUES 
(1,'version','0');
UNLOCK TABLES;
```

Example for data.json
```javascript
[
    {"_id":"app::version","app":"startx-db-tools","stage":"dev","version":"0.0.2"}
]
```

### 4. Run your application

without action

```bash
docker run -d \
    --link db-mysql \
    --link db-couchbase \
    startx/db-tools
```

or using environement variable and init global action

```bash
docker run -d \
    --link db-mysql \
    --link db-couchbase \
    -v ./mounts/mysql-dump:/data/mysql-dump:Z \
    -v ./mounts/couchbase-dump:/data/couchbase-dump:Z \
    --env MYSQL_HOST=db-mysql \
    --env MYSQL_USER=root \
    --env MYSQL_PASSWORD=root \
    --env MYSQL_DATABASE=dev \
    --env MYSQL_DATABASE_USER=dev \
    --env MYSQL_DATABASE_PASSWORD=dev \
    --env MYSQL_DUMP_DIR=/tmp/mysql-dump \
    --env MYSQL_DUMP_ISEXTENDED=true \
    --env COUCHBASE_HOST=db-couchbase \
    --env COUCHBASE_USER=dev \
    --env COUCHBASE_PASSWORD=dev \
    --env COUCHBASE_BUCKET=dev \
    --env COUCHBASE_DUMP_DIR=/tmp/couchbase-dump \
    startx/db-tools \
    init
```

### 6. See result

You can connect to your database backend to see created database or look at volumes 














































### Container with default configuration

1. Get the last version of sxapi container from docker hub registry
```bash
docker pull startx/sxapi:latest
```

2. Run your sample application
```bash
// run on port 8080 and attach console
docker run startx/sxapi
// or run in detached mode and expose port 81
docker run -d -p 81:8080 startx/sxapi
```

3. Connect to `http://localhost:8080` or `http://localhost:81` 
with your favorite navigator


### Container with your own configuration (docker)

The purpose of sxapi is to help you build your own api microservice. 
when using our container version, you can follow these step :

1. Get the last version of sxapi container from docker hub registry
```bash
docker pull startx/sxapi:latest
```

2. Create a file named sxapi.json and edit it with the following content
```javascript
{
    "name": "sample-api",
    "description": "my sample api using sxapi-core framework",
    "version": "0.0.0",
    "debug": true,
    "log": {
        "filters": {
            "level": "0,1,2,3,4",
            "type": "debug,info,error,warn"
        }
    },
    "server": {
        "endpoints": [
            {
                "path": "/",
                "body": "<html><head></head><body><h1>My sample API</h1></body></html>"
            }
        ]
    }
}
```

3. Run your application
```bash
docker run -d -p 8080:8080 -v $(pwd)/sxapi.json:/conf/sxapi.json:ro startx/sxapi
```

4. Connect to `http://localhost:8080` with your favorite navigator


### Container with your own configuration (docker-compose)

If you use docker-compose, you can use the following docker-compose.yml 
sample file
```yaml
api:
  image: startx/sxapi:latest
  container_name: "my-api"
  ports:
    - "8080:8080"
  volumes:
  - "./sxapi-test.json:/conf/sxapi.json:ro"
```

1. Create your `docker-compose.yml` file with the previous content

2. Create a file named sxapi.json and edit it with the following content
```javascript
{
    "name": "sample-api",
    "description": "my sample api using sxapi-core framework",
    "version": "0.0.0",
    "debug": true,
    "log": {
        "filters": {
            "level": "0,1,2,3,4",
            "type": "debug,info,error,warn"
        }
    },
    "server": {
        "endpoints": [
            {
                "path": "/",
                "body": "<html><head></head><body><h1>My sample API</h1></body></html>"
            }
        ]
    }
}
```

3. Run your application
```bash
docker-compose up
```

4. Connect to `http://localhost:8080` with your favorite navigator