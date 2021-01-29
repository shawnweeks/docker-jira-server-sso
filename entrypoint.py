#!/usr/bin/python2

from entrypoint_helpers import env, gen_cfg, set_props

JIRA_HOME = env["JIRA_HOME"]
JIRA_INSTALL_DIR = env["JIRA_INSTALL_DIR"]

gen_cfg("server.xml.j2", "{}/conf/server.xml".format(JIRA_INSTALL_DIR))

if "ATL_CROWD_SSO_ENABLED" in env and env["ATL_CROWD_SSO_ENABLED"] == "true":
    gen_cfg("seraph-config.xml.j2", "{}/atlassian-jira/WEB-INF/classes/seraph-config.xml".format(JIRA_INSTALL_DIR))
    gen_cfg("web.xml.j2", "{}/atlassian-jira/WEB-INF/web.xml".format(JIRA_INSTALL_DIR))
    gen_cfg("login.jsp.j2", "{}/atlassian-jira/login.jsp".format(JIRA_INSTALL_DIR))
    gen_cfg("crowd.properties.j2", "{}/atlassian-jira/WEB-INF/classes/crowd.properties".format(JIRA_INSTALL_DIR))
    props = {
        "jira.websudo.is.disabled":"true",
        "jira.disable.login.gadget":"true",
    }
    set_props(props,"{}/jira-config.properties".format(JIRA_HOME))