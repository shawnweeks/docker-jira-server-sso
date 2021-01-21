#!/bin/bash

set -e
umask 0027

: ${JAVA_OPTS:=}
: ${CATALINA_OPTS:=}

export JAVA_OPTS="${JAVA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS}"

shutdownCleanup() {
    if [[ -f ${JIRA_HOME}/.jira-home.lock ]]
    then
        echo "Cleaning Up Jira Locks"
        rm ${JIRA_HOME}/.jira-home.lock
    fi
}

entrypoint.py
trap "shutdownCleanup" INT
${JIRA_INSTALL_DIR}/bin/start-jira.sh -fg