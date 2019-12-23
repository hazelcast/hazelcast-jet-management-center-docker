FROM openjdk:8u201-jre-alpine

ENV MC_VERSION 3.2.1
ENV MC_HOME /opt/hazelcast-jet-management-center

ARG HZ_KUBE_VERSION=1.4
ARG HZ_EUREKA_VERSION=1.1.1
ARG HZ_AWS_VERSION=2.4

ARG MC_INSTALL_NAME="hazelcast-jet-management-center-${MC_VERSION}"
ARG MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"
ARG MC_INSTALL_DIR="${MC_HOME}/${MC_INSTALL_NAME}"
ARG MC_INSTALL_JAR="hazelcast-jet-management-center-${MC_VERSION}.jar"
ARG HZ_AWS_API_JAR="hazelcast-aws-${HZ_AWS_VERSION}.jar"

ENV MC_RUNTIME "${MC_INSTALL_DIR}/${MC_INSTALL_JAR}"

# Install curl to download management center
RUN apk add --no-cache bash curl \
 && rm -rf /var/cache/apk/*

# chmod allows running container as non-root with `docker run --user` option
RUN mkdir -p ${MC_HOME}/lib \
 && chmod a+rwx ${MC_HOME}
WORKDIR ${MC_HOME}

# Prepare Management Center
RUN curl -svf -o ${MC_HOME}/${MC_INSTALL_ZIP} \
         -L https://download.hazelcast.com/hazelcast-jet-management-center/${MC_INSTALL_ZIP} \
 && unzip ${MC_INSTALL_ZIP} \
      -x ${MC_INSTALL_NAME}/manual/* \
 && rm -rf ${MC_INSTALL_ZIP}

# Download & install Hazelcast AWS Module
RUN curl -svf -o ${MC_HOME}/lib/${HZ_AWS_API_JAR} \
         -L https://repo1.maven.org/maven2/com/hazelcast/hazelcast-aws/${HZ_AWS_VERSION}/${HZ_AWS_API_JAR}

# Download and install Hazelcast plugins (hazelcast-kubernetes and hazelcast-eureka) with dependencies
# Use Maven Wrapper to fetch dependencies specified in mvnw/dependency-copy.xml
RUN curl -svf -o ${MC_HOME}/maven-wrapper.tar.gz \
         -L https://github.com/takari/maven-wrapper/archive/maven-wrapper-0.3.0.tar.gz \
 && tar zxf maven-wrapper.tar.gz \
 && rm -fr maven-wrapper.tar.gz \
 && mv maven-wrapper* mvnw
COPY mvnw ${MC_HOME}/mvnw
RUN cd mvnw \
 && chmod +x mvnw \
 && sync \
 && ./mvnw -f dependency-copy.xml \
           -Dhazelcast-kubernetes-version=${HZ_KUBE_VERSION} \
           -Dhazelcast-eureka-version=${HZ_EUREKA_VERSION} \
           dependency:copy-dependencies \
 && cd .. \
 && rm -rf $MC_HOME/mvnw \
 && rm -rf ~/.m2 \
 && chmod -R +r $MC_HOME

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
