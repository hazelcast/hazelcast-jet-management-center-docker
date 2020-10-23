FROM registry.access.redhat.com/ubi8/ubi
MAINTAINER Hazelcast, Inc. Jet Integration Team <info@hazelcast.com>

ENV USER_NAME="jet" \
        USER_UID=10001

ARG MC_VERSION=4.3
ENV MC_HOME /opt/hazelcast-jet-management-center

ARG HZ_KUBE_VERSION=2.0.1
ARG HZ_EUREKA_VERSION=1.1.2
ARG HZ_AWS_VERSION=3.0

ARG MC_INSTALL_NAME="hazelcast-jet-management-center-${MC_VERSION}"
ARG MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"
ARG MC_INSTALL_DIR="${MC_HOME}/${MC_INSTALL_NAME}"
ARG MC_INSTALL_JAR="hazelcast-jet-management-center-${MC_VERSION}.jar"

ENV MC_RUNTIME "${MC_INSTALL_DIR}/${MC_INSTALL_JAR}"

LABEL name="hazelcast/hazelcast-jet-management-center" \
        vendor="Hazelcast, Inc." \
        version="8.1" \
        architecture="x86_64" \
        release="${MC_VERSION}" \
        url="http://www.hazelcast.com" \
        summary="Hazelcast Jet Management Center Openshift Image, certified to RHEL 8" \
        description="Starts a Hazelcast Jet Management Center instance to monitor and manage Hazelcast Jet based on kubernetes discovery inside Openshift" \
        io.k8s.description="Starts a Hazelcast Jet Management Center instance to monitor and manage Hazelcast Jet based on kubernetes discovery inside Openshift" \
        io.k8s.display-name="Hazelcast Jet Management Center" \
        io.openshift.expose-services="8081:http" \
        io.openshift.tags="jet,monitoring,java8,kubernetes,rhel8"

COPY description.md /tmp/
COPY licenses /licenses
COPY mvnw ${MC_HOME}/mvnw

RUN mkdir -p ${MC_HOME}/lib && \
        ### Disable subscription-manager plugin to prevent redundant logs
        sed -i 's/^enabled=.*/enabled=0/g' /etc/dnf/plugins/subscription-manager.conf && \
        dnf config-manager --disable && \
        dnf update -y  && rm -rf /var/cache/dnf && \
        dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
        ### Add your package needs to this installation line
        dnf -y --setopt=tsflags=nodocs install java-1.8.0-openjdk-devel unzip &> /dev/null && \
        ### Install go-md2man to help markdown to man conversion
        dnf -y --setopt=tsflags=nodocs install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &> /dev/null && \
        dnf -y --setopt=tsflags=nodocs install golang-github-cpuguy83-go-md2man &> /dev/null && \
        go-md2man -in /tmp/description.md -out /help.1 && \
        dnf -y remove golang-github-cpuguy83-go-md2man && \
        dnf -y clean all 

WORKDIR ${MC_HOME}

# Prepare Management Center
RUN curl -svf -o ${MC_HOME}/${MC_INSTALL_ZIP} \
        -L https://download.hazelcast.com/hazelcast-jet-management-center/${MC_INSTALL_ZIP} \
        && unzip ${MC_INSTALL_ZIP} \
        -x ${MC_INSTALL_NAME}/manual/* \
        && rm -rf ${MC_INSTALL_ZIP}

# Download and install Hazelcast plugins (hazelcast-kubernetes and hazelcast-eureka) with dependencies
# Use Maven Wrapper to fetch dependencies specified in mvnw/dependency-copy.xml
RUN cd mvnw \
        && chmod +x mvnw \
        && sync \
        && ./mvnw -f dependency-copy.xml \
        -Dhazelcast-kubernetes-version=${HZ_KUBE_VERSION} \
        -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
        dependency:copy-dependencies \
        && cd .. \
        && rm -rf $MC_HOME/mvnw \
        && rm -rf ~/.m2 && \
        useradd -l -u $USER_UID -r -g 0 -d $MC_HOME -s /sbin/nologin -c "${USER_UID} application user" $USER_NAME && \
        chown -R $USER_UID:0 $MC_HOME && \
        chmod -R g=u "$MC_HOME" && \
        chmod -R +r $MC_HOME

COPY hazelcast.yaml ${MC_HOME}/config/hazelcast.yaml

# Runtime environment variables
ENV CLASSPATH_DEFAULT "${MC_RUNTIME}"
ENV LOADER_PATH "${MC_HOME}/lib"
ENV JAVA_OPTS_DEFAULT "-Djava.net.preferIPv4Stack=true -Dloader.path=${LOADER_PATH}"

ENV MIN_HEAP_SIZE ""
ENV MAX_HEAP_SIZE ""

ENV JAVA_OPTS ""
ENV CLASSPATH ""

ENV CLI_ARGS ""
ENV MC_HTTP_PORT 8081
ENV MC_LICENSE_KEY ""
ENV MC_CLIENT_CONFIG ""
ENV MC_APPLICATION_CONFIG ""
ENV MC_USER ""
ENV MC_PASSWORD ""

### Switch to jet user
USER $USER_UID

EXPOSE ${MC_HTTP_PORT}

# Start Management Center
CMD ["bash", "-c", "set -euo pipefail \
        && if [[ \"x${CLASSPATH}\" != \"x\" ]]; then export CLASSPATH=\"${CLASSPATH_DEFAULT}:${CLASSPATH}\"; else export CLASSPATH=\"${CLASSPATH_DEFAULT}\"; fi \
        && if [[ \"x${JAVA_OPTS}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}\"; else export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT}\"; fi \
        && if [[ \"x${MIN_HEAP_SIZE}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS} -Xms${MIN_HEAP_SIZE}\"; fi \
        && if [[ \"x${MAX_HEAP_SIZE}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS} -Xms${MAX_HEAP_SIZE}\"; fi \
        && if [[ \"x${MC_HTTP_PORT}\" != \"x\" ]]; then export CLI_ARGS=\"${CLI_ARGS} -p ${MC_HTTP_PORT}\"; fi \
        && if [[ \"x${MC_LICENSE_KEY}\" != \"x\" ]]; then export CLI_ARGS=\"${CLI_ARGS} -l ${MC_LICENSE_KEY}\"; fi \
        && if [[ \"x${MC_CLIENT_CONFIG}\" != \"x\" ]]; then export CLI_ARGS=\"${CLI_ARGS} -c ${MC_CLIENT_CONFIG}\"; fi \
        && if [[ \"x${MC_APPLICATION_CONFIG}\" != \"x\" ]]; then export CLI_ARGS=\"${CLI_ARGS} -f ${MC_APPLICATION_CONFIG}\"; fi \
        && if [[ \"x${MC_USER}\" != \"x\" ]]; then export CLI_ARGS=\"${CLI_ARGS} -U ${MC_USER}\"; fi \
        && if [[ \"x${MC_PASSWORD}\" != \"x\" ]]; then export CLI_ARGS=\"${CLI_ARGS} -P ${MC_PASSWORD}\"; fi \
        && echo \"########################################\" \
        && echo \"# JAVA_OPTS=${JAVA_OPTS}\" \
        && echo \"# CLASSPATH=${CLASSPATH}\" \
        && echo \"# starting now....\" \
        && echo \"########################################\" \
        && set -x \
        && exec java -server ${JAVA_OPTS} org.springframework.boot.loader.PropertiesLauncher ${CLI_ARGS} \
        "]
