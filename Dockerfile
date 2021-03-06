# Atlassian Docker UIDs
# These are based on the UIDs found in the Official Images
# to maintain compatability as much as possible.
# Jira          2001
# Confluence    2002
# Bitbucket     2003
# JIRA         2004
# Bamboo        2005
ARG BASE_REGISTRY
ARG BASE_IMAGE=redhat/ubi/ubi8
ARG BASE_TAG=8.3

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as build

ARG JIRA_VERSION
ARG JIRA_PACKAGE=atlassian-jira-software-${JIRA_VERSION}.tar.gz

COPY [ "${JIRA_PACKAGE}", "/tmp/" ]

RUN mkdir -p /tmp/jira_package && \
    tar -xf /tmp/${JIRA_PACKAGE} -C "/tmp/jira_package" --strip-components=1


###############################################################################
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ENV JIRA_USER jira
ENV JIRA_GROUP jira
ENV JIRA_UID 2001
ENV JIRA_GID 2001

ENV JIRA_HOME /var/atlassian/application-data/jira
ENV JIRA_INSTALL_DIR /opt/atlassian/jira

RUN yum install -y java-11-openjdk-devel && \
    yum clean all && \    
    mkdir -p ${JIRA_HOME}/{log,shared} && \
    mkdir -p ${JIRA_INSTALL_DIR} && \
    groupadd -r -g ${JIRA_GID} ${JIRA_GROUP} && \
    useradd -r -u ${JIRA_UID} -g ${JIRA_GROUP} -M -d ${JIRA_HOME} ${JIRA_USER} && \
    touch ${JIRA_HOME}/jira-config.properties && \
    chown ${JIRA_USER}:${JIRA_GROUP} ${JIRA_HOME} -R && \
    chown ${JIRA_USER}:${JIRA_GROUP} ${JIRA_INSTALL_DIR} -R

COPY [ "templates/*.j2", "/opt/jinja-templates/" ]
COPY --from=build --chown=${JIRA_USER}:${JIRA_GROUP} [ "/tmp/jira_package", "${JIRA_INSTALL_DIR}/" ]
COPY --chown=${JIRA_USER}:${JIRA_GROUP} [ "entrypoint.sh", "entrypoint.py", "entrypoint_helpers.py", "${JIRA_INSTALL_DIR}/" ]

RUN sed -i -e 's/^JVM_SUPPORT_RECOMMENDED_ARGS=""$/: \${JVM_SUPPORT_RECOMMENDED_ARGS:=""}/g' ${JIRA_INSTALL_DIR}/bin/setenv.sh && \
    sed -i -e 's/^JVM_\(.*\)_MEMORY="\(.*\)"$/: \${JVM_\1_MEMORY:=\2}/g' ${JIRA_INSTALL_DIR}/bin/setenv.sh && \
    sed -i -e 's/-XX:ReservedCodeCacheSize=\([0-9]\+[kmg]\)/-XX:ReservedCodeCacheSize=${JVM_RESERVED_CODE_CACHE_SIZE:=\1}/g' ${JIRA_INSTALL_DIR}/bin/setenv.sh && \    
    chmod 755 ${JIRA_INSTALL_DIR}/entrypoint.*

EXPOSE 8080

VOLUME ${JIRA_HOME}
USER ${JIRA_USER}
ENV JAVA_HOME=/usr/lib/jvm/java-11
ENV PATH=${PATH}:${JIRA_INSTALL_DIR}
WORKDIR ${JIRA_HOME}
ENTRYPOINT [ "entrypoint.sh" ]