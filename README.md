# Hazelcast Jet Management Center Docker Image

Hazelcast Jet Management Center enables you to monitor and manage your cluster members running Hazelcast Jet. In addition to monitoring the overall state of your clusters, you can also analyze and browse your jobs in detail.

You can check [Hazelcast Jet Documentation](http://docs.hazelcast.org/docs/jet/latest-dev/manual) and [Hazelcast Jet Management Center Documentation]() for more information.

## Quick Start

You can launch Hazelcast Jet Management Center by simply running the following command. please check available versions for $HAZELCAST_JET_MANAGEMENT_CENTER on [Docker Store](https://store.docker.com/community/images/hazelcast/hazelcast-jet-management-center/tags)

```
docker run -p 8081:8081 hazelcast/hazelcast-jet-management-center:$HAZELCAST_JET_MANAGEMENT_CENTER
```

Now you can reach Hazelcast Jet Management Center from your browser using the URL `http://localhost:8081`. 

If you are running the Docker image in the cloud, you should use a public IP of your machine instead of `localhost`. 

`docker ps` and `docker inspect <container-id>` can be used to find `host-ip`. Once you find out `host-ip`, you can browse Hazelcast Jet Management Center using the URL: `http://host-ip:8081`.

## Configuration

Hazelcast Jet Management Center uses Hazelcast Jet Client to discover the Hazelcast Jet Cluster. You might need to provide a Hazelcast Jet Client XML Configuration file to be able to discover and connect to the Hazelcast Jet Cluster.

## Using Custom Hazelcast Jet Client XML Configuration File

If you need to configure Hazelcast with your own `hazelcast-client.xml`, you need to mount the folder that has `hazelcast-client.xml`. You also need to pass the `hazelcast-client.xml` file path to `jet.clientXml` in `JAVA_OPTS` parameter. Please see the following example:

```
$ docker run -p 8081:8081 -e JAVA_OPTS="-Djet.clientXml=/opt/hazelcast/config_ext/hazelcast-client.xml" -v PATH_TO_LOCAL_CONFIG_FOLDER:/opt/hazelcast/config_ext hazelcast/hazelcast-jet-management-center
```

## License Key Configuration

Hazelcast Jet Management Center free trial is limited to a single node. If you have a bigger cluster you can [apply for a trial](https://hazelcast.com/hazelcast-enterprise-download/). To provide a license key to docker container the system property `jet.licenseKey` can be used:

```
docker run -e JAVA_OPTS='-Djet.licenseKey=<your-license-key>' -p 8081:8081 hazelcast/hazelcast-jet-management-center:$MANAGEMENT_CENTER
```

## Extending CLASSPATH with new jars or files

If you have custom jars or files to put into classpath of docker container, you can simply use `CLASSPATH` environment variable and pass it via `docker run` command. Please see the following example:

```
$ docker run -e CLASSPATH="/opt/hazelcast-jet/CLASSPATH_EXT/" -v PATH_TO_LOCAL_CONFIG_FOLDER:/opt/hazelcast/CLASSPATH_EXT hazelcast/hazelcast-jet-management-center
```

# Kubernetes Deployment

Hazelcast Jet Management Center is prepared to work in the Kubernetes environment. For details, please check:

* [Hazelcast Jet Kubernetes Code Sample](https://github.com/hazelcast/hazelcast-jet-code-samples/)
