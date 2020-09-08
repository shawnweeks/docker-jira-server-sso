#!/usr/bin/python3

from entrypoint_helpers import env, gen_cfg, set_props

JIRA_HOME = env['JIRA_HOME']
JIRA_INSTALL_DIR = env['JIRA_INSTALL_DIR']

gen_cfg('server.xml.j2', f'{JIRA_INSTALL_DIR}/conf/server.xml')

if 'CROWD_SSO_ENABLED' in env and env['CROWD_SSO_ENABLED'] == 'true':
    gen_cfg('seraph-config.xml.j2', f'{JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/seraph-config.xml')
    gen_cfg('web.xml.j2', f'{JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/web.xml')
    gen_cfg('login.jsp.j2', f'{JIRA_INSTALL_DIR}/atlassian-jira/login.jsp')
    gen_cfg('crowd.properties.j2', f'{JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/crowd.properties')
    props = {
        "jira.websudo.is.disabled":"true",
        "jira.disable.login.gadget":"true",
    }
    set_props(props,f'{JIRA_HOME}/jira-config.properties')