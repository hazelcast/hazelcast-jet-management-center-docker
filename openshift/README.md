# Hazelcast Jet Management Center OpenShift Image

Hazelcast Jet Management Center is available on the OpenShift platform in a
form of a dedicated Docker image
[`registry.connect.redhat.com/hazelcast/hazelcast-jet-management-center-4`](https://access.redhat.com/containers/?tab=overview#/registry.connect.redhat.com/hazelcast/hazelcast-jet-management-center-4)
published in [Red Hat Container Catalog](https://access.redhat.com/containers/).

## Quick Start

Create an OpenShift secret with the Hazelcast Jet Enterprise License
Key.

    $ oc create secret generic jet-license-key --from-literal=key=LICENSE-KEY-HERE

Creates secret to allow access to Red Hat Container Catalog.

    $ oc create secret docker-registry rhcc \
       --docker-server=registry.connect.redhat.com \
       --docker-username=<red_hat_username> \
       --docker-password=<red_hat_password> \
       --docker-email=<red_hat_email>
    $ oc secrets link default rhcc --for=pull

Then, here's an example of a simple template that can be used to start a
Hazelcast Jet Management Center (don't forget to replace
`<hazelcast-jet-service-name>` and `<project-name>` of
`HAZELCAST_KUBERNETES_SERVICE_DNS` which with the values which
corresponds to a target Hazelcast Jet cluster and `<image-version>` in
the template).

```
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: hazelcast-jet-management-center
objects:
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: hazelcast-jet-management-center-configuration
  data:
    hazelcast-client.yaml: |-
        hazelcast-client:
          cluster-name: jet
          network:
            kubernetes:
              enabled: true
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: hazelcast-jet-management-center
    labels:
      app: hazelcast-jet-management-center
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: hazelcast-jet-management-center
    template:
      metadata:
        labels:
          app: hazelcast-jet-management-center
      spec:
        containers:
        - name: hazelcast-jet-management-center
          image: registry.connect.redhat.com/hazelcast/hazelcast-jet-management-center-4:<version>
          ports:
            - name: mc-port
              containerPort: 8081
          livenessProbe:
            httpGet:
              path: /
              port: 8081
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /
              port: 8081
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 1
          volumeMounts:
          - name: hazelcast-jet-management-center-storage
            mountPath: /data/hazelcast-jet-management-center
          env:
          - name: HAZELCAST_KUBERNETES_SERVICE_DNS
            value: <hazelcast-jet-service-name>.<project-name>.svc.cluster.local
          - name: MC_LICENSE_KEY
            valueFrom:
              secretKeyRef:
                name: jet-license-key
                key: key
          - name: JAVA_OPTS
            value: "-Djet.clientConfig=/data/hazelcast-jet-management-center/hazelcast-client.yaml"
        volumes:
        - name: hazelcast-jet-management-center-storage
          configMap:
            name: hazelcast-jet-management-center-configuration
            items:
              - key: hazelcast-client.yaml
                path: hazelcast-client.yaml
- apiVersion: v1
  kind: Service
  metadata:
    name: hazelcast-jet-management-center-service
  spec:
    type: LoadBalancer
    selector:
      app: hazelcast-jet-management-center
    ports:
    - protocol: TCP
      port: 8081
      targetPort: mc-port
      name: mc-port
```

If you save it as `hazelcast-jet-management-center.yaml`, then use the following command to
start the cluster.

    $ oc new-app -f hazelcast-jet-management-center.yaml

**Note**: _You should always use `<kubernetes>` discovery in OpenShift;
defining static IPs usually does not make sense, since POD IP is
dynamically assigned._
