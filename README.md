# Hazelcast Jet Management Center Docker Image

Hazelcast Jet Management Center enables you to monitor and manage your
cluster members running Hazelcast Jet. In addition to monitoring the
overall state of your clusters, you can also analyze and browse your
jobs in detail.

You can check 
[Hazelcast Jet Documentation](https://jet-start.sh/docs/next/get-started/intro)
and [Hazelcast Jet Management Center Documentation](https://jet-start.sh/docs/enterprise/management-center) for more 
information.

## Quick Start

You can launch Hazelcast Jet Management Center by simply running the
following command. Please check available versions for 
`$HAZELCAST_JET_MANAGEMENT_CENTER_VERSION` on 
[Docker Store](https://store.docker.com/community/images/hazelcast/hazelcast-jet-management-center/tags)

```
docker run -p 8081:8081 hazelcast/hazelcast-jet-management-center:$HAZELCAST_JET_MANAGEMENT_CENTER_VERSION
```

Now you can reach Hazelcast Jet Management Center from your browser
using the URL `http://localhost:8081`. 

If you are running the Docker image in the cloud, you should use a
public IP of your machine instead of `localhost`. 

`docker ps` and `docker inspect <container-id>` can be used to find
`host-ip`. Once you find out `host-ip`, you can browse Hazelcast Jet
Management Center using the URL: `http://host-ip:8081`.

## Configuration

Hazelcast Jet Management Center uses Hazelcast Jet Client to discover
the Hazelcast Jet Cluster. You might need to provide a Hazelcast Jet
Client XML Configuration file to be able to discover and connect to the
Hazelcast Jet Cluster.

## Using Custom Hazelcast Jet Client XML Configuration File

If you need to configure Hazelcast with your own `hazelcast-client.xml`,
you need to mount the folder that has `hazelcast-client.xml`. You also
need to pass the `hazelcast-client.xml` file path as `MC_CLIENT_CONFIG`
environment variable. Please see the following example:

```
$ docker run -p 8081:8081 -e MC_CLIENT_CONFIG="/opt/hazelcast/config_ext/hazelcast-client.xml" -v PATH_TO_LOCAL_CONFIG_FOLDER:/opt/hazelcast/config_ext hazelcast/hazelcast-jet-management-center:$HAZELCAST_JET_MANAGEMENT_CENTER_VERSION
```

## License Key Configuration

Hazelcast Jet Management Center free trial is limited to a single node.
If you have a bigger cluster you can 
[apply for a trial](https://hazelcast.com/hazelcast-enterprise-download/).
To provide a license key to docker container `MC_LICENSE_KEY`
environment variable can be used:

```
docker run -e MC_LICENSE_KEY=<your-license-key> -p 8081:8081 hazelcast/hazelcast-jet-management-center:$HAZELCAST_JET_MANAGEMENT_CENTER_VERSION
```

## Username and Password Configuration

Basic username and password authentication with a single user can be
configured on Hazelcast Jet Management Center to prevent unauthorized
parties to achieve unexpected actions on the Hazelcast Jet Cluster.

The username and password can be configured via environment variables
like following;

```
docker run -e MC_USER=username MC_PASSWORD=password -p 8081:8081 hazelcast/hazelcast-jet-management-center:$HAZELCAST_JET_MANAGEMENT_CENTER_VERSION
```

## Using Custom Properties File

Hazelcast Jet Management Center can be configured via a properties file
called `application.properties`.

The ZIP packaging includes an `application.properties` file that you
can override the configuration properties.

The default content of the `application.properties` file can be seen
below;

```properties
# path for client configuration file (yaml or xml)
jet.clientConfig=
# License key for management center
jet.licenseKey=

# How many seconds of data to retain for each metric
jet.metrics.retentionSecs=3600

# User Authentication Configuration
spring.security.user.name=admin
spring.security.user.password=admin

# Sever Configuration Options
# server.port: 8081

# SSL configuration options for the web server
# server.ssl.key-store: keystore.p12
# server.ssl.key-store-password: mypassword
# server.ssl.keyStoreType: PKCS12
# server.ssl.keyAlias: tomcat
```

To pass a custom properties file to the Hazelcast Jet Management Center,
`MC_APPLICATION_CONFIG` environment variable can be used like following:

```
$ docker run -p 8081:8081 -e MC_APPLICATION_CONFIG="/opt/hazelcast/config_ext/application.properties" -v PATH_TO_LOCAL_PROPERTIES_FOLDER:/opt/hazelcast/config_ext hazelcast/hazelcast-jet-management-center:$HAZELCAST_JET_MANAGEMENT_CENTER_VERSION
```

## Extending CLASSPATH with new jars or files

If you have custom jars or files to put into classpath of docker
container, you can simply use `CLASSPATH` environment variable and pass
it via `docker run` command. Please see the following example:

```
$ docker run -e CLASSPATH="/opt/hazelcast-jet/CLASSPATH_EXT/" -v PATH_TO_LOCAL_CONFIG_FOLDER:/opt/hazelcast/CLASSPATH_EXT hazelcast/hazelcast-jet-management-center:$HAZELCAST_JET_MANAGEMENT_CENTER_VERSION
```

# Kubernetes Deployment

Hazelcast Jet Management Center is prepared to work in the Kubernetes
environment. For details, please check:

* [Hazelcast Jet Kubernetes Code Sample](https://github.com/hazelcast/hazelcast-jet-docker/blob/master/examples/kubernetes)
