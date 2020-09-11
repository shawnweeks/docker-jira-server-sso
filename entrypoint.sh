#!/bin/bash

set -e
umask 0027

: ${JAVA_OPTS:=}
: ${CATALINA_OPTS:=}

export JAVA_OPTS="${JAVA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS}"

startup() {
    echo Starting Jira Server
    ${JIRA_INSTALL_DIR}/bin/start-jira.sh
    tail -F ${JIRA_HOME}/log/atlassian-jira.log
}

shutdown() {
    echo Stopping Jira Server
    ${JIRA_INSTALL_DIR}/bin/stop-jira.sh
}

trap "shutdown" INT
entrypoint.py
startup