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
    sleep 15
    tail -n +1 --retry -F ${JIRA_HOME}/log/*.log
}

shutdown() {
    echo Stopping Jira Server
    ${JIRA_INSTALL_DIR}/bin/stop-jira.sh
}

trap "shutdown" INT
entrypoint.py
startup