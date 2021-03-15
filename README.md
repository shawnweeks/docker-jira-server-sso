### Download Software
```shell
export JIRA_VERSION=8.13.4
wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${JIRA_VERSION}.tar.gz
```

### Build Command
```shell
docker build \
    -t ${REGISTRY}/atlassian-suite/jira-server-sso:${JIRA_VERSION} \
    --build-arg BASE_REGISTRY=${REGISTRY} \
    --build-arg JIRA_VERSION=${JIRA_VERSION} \
    .
```

### Push to Registry
```shell
docker push ${REGISTRY}/atlassian-suite/jira-server-sso
```

### Simple Run Command
```shell
docker run --init -it --rm \
    --name jira  \
    -v jira-data:/var/atlassian/application-data/jira \
    -p 8080:8080 \
    ${REGISTRY}/atlassian-suite/jira-server-sso:${JIRA_VERSION}
```

### SSO Run Command
```shell
# Run first and setup Crowd Directory
docker run --init -it --rm \
    --name jira  \
    -v jira-data:/var/atlassian/application-data/jira \
    -p 8080:8080 \
    -e ATL_TOMCAT_CONTEXTPATH='/jira' \
    -e ATL_TOMCAT_SCHEME='https' \
    -e ATL_TOMCAT_SECURE='true' \
    -e ATL_TOMCAT_PROXY_NAME='cloudbrocktec.com' \
    -e ATL_TOMCAT_PROXY_PORT='443' \
    ${REGISTRY}/atlassian-suite/jira-server-sso:${JIRA_VERSION}

# Run second after you've setup the crowd connection
docker run --init -it --rm \
    --name jira  \
    -v jira-data:/var/atlassian/application-data/jira \
    -p 8080:8080 \
    -e ATL_TOMCAT_CONTEXTPATH='/jira' \
    -e ATL_TOMCAT_SCHEME='https' \
    -e ATL_TOMCAT_SECURE='true' \
    -e ATL_TOMCAT_PROXY_NAME='cloudbrocktec.com' \
    -e ATL_TOMCAT_PROXY_PORT='443' \
    -e ATL_CROWD_SSO_ENABLED='true' \
    -e ATL_SSO_LOGIN_URL='https://cloudbrocktec.com/spring-crowd-sso/saml/login' \
    -e ATL_CROWD_APP_NAME='jira' \
    -e ATL_CROWD_APP_PASS='jira' \
    -e ATL_CROWD_BASE_URL='https://cloudbrocktec.com/crowd' \
    ${REGISTRY}/atlassian-suite/jira-server-sso:${JIRA_VERSION}
```

### Environment Variables
| Variable Name | Description | Default Value |
| --- | --- | --- |
| ATL_TOMCAT_PORT | The port jira listens on, this may need to be changed depending on your environment. | 8080 |
| ATL_TOMCAT_SCHEME | The protocol via which jira is accessed | http |
| ATL_TOMCAT_SECURE | Set to true if `ATL_TOMCAT_SCHEME` is 'https' | false |
| ATL_TOMCAT_CONTEXTPATH | The context path the application is served over | None |
| ATL_TOMCAT_PROXY_NAME | The reverse proxys full URL for jira | None |
| ATL_TOMCAT_PROXY_PORT | The reverse proxy's port number | None |
| ATL_TOMCAT_SSL_ENABLED | Enable Tomcat SSL Support | None |
| ATL_TOMCAT_SSL_ENABLED_PROTOCOLS | Allowed SSL Protocols | TLSv1.2,TLSv1.3 |
| ATL_TOMCAT_KEY_ALIAS | Tomcat SSL Key Alias | None |
| ATL_TOMCAT_KEYSTORE_FILE | Tomcat SSL Keystore File | None |
| ATL_TOMCAT_KEYSTORE_PASSWORD | Tomcat SSL Keystore Password | None |
| ATL_TOMCAT_KEYSTORE_TYPE | Tomcat SSL Keystore Type | JKS |
| ATL_SSO_LOGIN_URL | Login URL for Custom SSO Support | None |
| ATL_CROWD_SSO_ENABLED | Enable Crowd SSO Support | false |
| ATL_CROWD_APP_NAME | Crowd Application Name, Required if for Crowd SSO. | None |
| ATL_CROWD_APP_PASSWORD | Crowd Application Password, Required if for Crowd SSO. | None |
| ATL_CROWD_BASE_URL | Crowd's Base URL | None |
| ATL_JAVA_ARGS | Support recomended Java Arguments | None |
| ATL_MIN_MEMORY | Set's Java XMS | None |
| ATL_MAX_MEMORY | Set's Java XMX | None |

### Additional
#### Auto-login
By default when SSO is enabled, the app will automatically redirect to the SSO login app when the user hits the login page. This can be disabled by passing a query paramter in the login page URL. `auto_login=false`

Too prevent login redirect loops, a cookie is created when the user first hits the login page. Any hits on the login page within one minute afterwards will require the user to click a link to initiate a login.