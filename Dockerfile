# Atlassian Docker UIDs
# These are based on the UIDs found in the Official Images
# to maintain compatability as much as possible.
# Jira          2001
# Confluence    2002
# Bitbucket     2003
# Crowd         2004
# Bamboo        2005

ARG BASE_REGISTRY=registry.cloudbrocktec.com
ARG BASE_IMAGE=redhat/ubi/ubi7
ARG BASE_TAG=7.8

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ENV JIRA_USER jira
ENV JIRA_GROUP jira
ENV JIRA_UID 2001
ENV JIRA_GID 2001

ENV JIRA_HOME /var/atlassian/application-data/jira
ENV JIRA_INSTALL_DIR /opt/atlassian/jira

ARG JIRA_VERSION
ARG DOWNLOAD_URL=https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${JIRA_VERSION}.tar.gz

RUN yum install -y java-11-openjdk-devel procps git python2 python2-jinja2 && \
    yum clean all

COPY [ "entrypoint.sh", "entrypoint.py", "entrypoint_helpers.py", "/tmp/scripts/" ]

COPY [ "templates/*.j2", "/opt/jinja-templates/" ]

RUN mkdir -p ${JIRA_HOME}/shared && \
    mkdir -p ${JIRA_INSTALL_DIR} && \
    groupadd -r -g ${JIRA_GID} ${JIRA_GROUP} && \
    useradd -r -u ${JIRA_UID} -g ${JIRA_GROUP} -M -d ${JIRA_HOME} ${JIRA_USER} && \
    curl --silent -L ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$JIRA_INSTALL_DIR" && \
    sed -i -e 's/^JVM_SUPPORT_RECOMMENDED_ARGS=""$/: \${JVM_SUPPORT_RECOMMENDED_ARGS:=""}/g' ${JIRA_INSTALL_DIR}/bin/setenv.sh && \
    sed -i -e 's/^JVM_\(.*\)_MEMORY="\(.*\)"$/: \${JVM_\1_MEMORY:=\2}/g' ${JIRA_INSTALL_DIR}/bin/setenv.sh && \
    sed -i -e 's/-XX:ReservedCodeCacheSize=\([0-9]\+[kmg]\)/-XX:ReservedCodeCacheSize=${JVM_RESERVED_CODE_CACHE_SIZE:=\1}/g' ${JIRA_INSTALL_DIR}/bin/setenv.sh && \
    touch ${JIRA_HOME}/jira-config.properties && \
    chown -R "${JIRA_USER}:${JIRA_GROUP}" "${JIRA_INSTALL_DIR}" && \
    cp /tmp/scripts/* ${JIRA_INSTALL_DIR}/bin && \
    chown -R "${JIRA_USER}:${JIRA_GROUP}" "${JIRA_HOME}" && \
    chmod 755 ${JIRA_INSTALL_DIR}/bin/entrypoint.*

EXPOSE 8080

VOLUME ${JIRA_HOME}
USER ${JIRA_USER}
ENV JAVA_HOME=/usr/lib/jvm/java-11
ENV PATH=${PATH}:${JIRA_INSTALL_DIR}/bin
WORKDIR ${JIRA_HOME}
ENTRYPOINT [ "entrypoint.sh" ]