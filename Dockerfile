# Copyright (c) 2016-present Sonatype, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM registry.access.redhat.com/ubi8/ubi-minimal

LABEL name="Nexus Repository Manager" \
      maintainer="Sonatype <support@sonatype.com>" \
      vendor=Sonatype \
      version="3.41.1-01" \
      release="3.41.1" \
      url="https://sonatype.com" \
      summary="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      description="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      run="docker run -d --name NAME \
          -p 8081:8081 \
          IMAGE" \
      stop="docker stop NAME" \
      com.sonatype.license="Apache License, Version 2.0" \
      com.sonatype.name="Nexus Repository Manager base image" \
      io.k8s.description="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      io.k8s.display-name="Nexus Repository Manager" \
      io.openshift.expose-services="8081:8081" \
      io.openshift.tags="Sonatype,Nexus,Repository Manager"

ARG NEXUS_VERSION=3.41.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
ARG NEXUS_DOWNLOAD_SHA256_HASH=1ad45fd883f41005e7f89ccb9e504f09a9a5708eb996493b985eed09e6482faa
ARG NEXUS_BLOB_STORAGE=https://search.maven.org/remotecontent?filepath=org/sonatype/nexus/plugins/nexus-blobstore-google-cloud/0.41.0/nexus-blobstore-google-cloud-0.41.0.kar

# configure nexus runtime
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
    NEXUS_DATA=/nexus-data \
    NEXUS_CONTEXT='' \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work \
    DOCKER_TYPE='rh-docker'

# Install Java & tar
RUN microdnf update -y \
    && microdnf --setopt=install_weak_deps=0 --setopt=tsflags=nodocs install -y \
          java-1.8.0-openjdk-headless tar procps shadow-utils gzip \
    && microdnf clean all \
    && groupadd --gid 200 -r nexus \
    && useradd --uid 200 -r nexus -g nexus -s /bin/false -d /opt/sonatype/nexus -c 'Nexus Repository Manager user'

WORKDIR ${SONATYPE_DIR}

# Download nexus & setup directories
RUN curl -L ${NEXUS_DOWNLOAD_URL} --output nexus-${NEXUS_VERSION}-unix.tar.gz \
    && echo "${NEXUS_DOWNLOAD_SHA256_HASH} nexus-${NEXUS_VERSION}-unix.tar.gz" > nexus-${NEXUS_VERSION}-unix.tar.gz.sha256 \
    && sha256sum -c nexus-${NEXUS_VERSION}-unix.tar.gz.sha256 \
    && tar -xvf nexus-${NEXUS_VERSION}-unix.tar.gz \
    && rm -f nexus-${NEXUS_VERSION}-unix.tar.gz nexus-${NEXUS_VERSION}-unix.tar.gz.sha256 \
    && mv nexus-${NEXUS_VERSION} $NEXUS_HOME \
    && chown -R nexus:nexus ${SONATYPE_WORK} \
    && mv ${SONATYPE_WORK}/nexus3 ${NEXUS_DATA} \
    && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3

RUN echo "#!/bin/bash" >> ${SONATYPE_DIR}/start-nexus-repository-manager.sh \
   && echo "cd /opt/sonatype/nexus" >> ${SONATYPE_DIR}/start-nexus-repository-manager.sh \
   && echo "exec ./bin/nexus run" >> ${SONATYPE_DIR}/start-nexus-repository-manager.sh \
   && chmod a+x ${SONATYPE_DIR}/start-nexus-repository-manager.sh

RUN microdnf remove -y tar gzip shadow-utils

# Download Nexus GCP Storage
RUN curl -L ${NEXUS_BLOB_STORAGE} --output nexus-blobstore-google-cloud-0.41.0.kar \
    && cp nexus-blobstore-google-cloud-0.41.0.kar /opt/sonatype/nexus/deploy

# Copy permission
COPY creds/ccx-technical-assesment-e4421e7ff97d.json ${NEXUS_DATA}
RUN export GOOGLE_APPLICATION_CREDENTIALS=${NEXUS_DATA}/ccx-technical-assesment-e4421e7ff97d.json

VOLUME ${NEXUS_DATA}

EXPOSE 8081
USER nexus

ENV INSTALL4J_ADD_VM_PARAMS="-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Djava.util.prefs.userRoot=${NEXUS_DATA}/javaprefs"

CMD ["/opt/sonatype/nexus/bin/nexus", "run"]

###############

# FROM sonatype/nexus3

# RUN mkdir /nexus
# RUN mkdir /nexus/nexus-data
# RUN cd /nexus
# RUN wget https://search.maven.org/remotecontent?filepath=org/sonatype/nexus/plugins/nexus-blobstore-google-cloud/0.41.0/nexus-blobstore-google-cloud-0.41.0.kar
# RUN cp nexus-blobstore-google-cloud-0.41.0.kar /nexus

# VOLUME /nexus/nexus-data

# COPY quickstart.sh /
# CMD ["/quickstart.sh"]