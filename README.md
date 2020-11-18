### Download Software
```shell
wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-8.12.3.tar.gz
```

### Build Command
```shell
docker build \
    -t $REGISTRY/atlassian-suite/jira-server-sso:8.12.3 \
    --build-arg BASE_REGISTRY=$REGISTRY \
    --build-arg JIRA_VERSION=8.12.3 \
    .
```

### Push to Registry
```shell
docker push $REGISTRY/atlassian-suite/jira-server-sso
```

### Simple Run Command
```shell
docker run --init -it --rm \
    --name jira  \
    -v jira-data:/var/atlassian/application-data/jira \
    -p 8080:8080 \
    registry.cloudbrocktec.com/atlassian-suite/jira-server-sso:8.12.1
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
    -e ATL_PROXY_NAME='cloudbrocktec.com' \
    -e ATL_PROXY_PORT='443' \
    registry.cloudbrocktec.com/atlassian-suite/jira-server-sso:8.12.1

# Run second after you've setup the crowd connection
docker run --init -it --rm \
    --name jira  \
    -v jira-data:/var/atlassian/application-data/jira \
    -p 8080:8080 \
    -e ATL_TOMCAT_CONTEXTPATH='/jira' \
    -e ATL_TOMCAT_SCHEME='https' \
    -e ATL_TOMCAT_SECURE='true' \
    -e ATL_PROXY_NAME='cloudbrocktec.com' \
    -e ATL_PROXY_PORT='443' \
    -e CROWD_SSO_ENABLED='true' \
    -e CUSTOM_SSO_LOGIN_URL='https://cloudbrocktec.com/spring-crowd-sso/saml/login' \
    -e CROWD_APP_NAME='jira' \
    -e CROWD_APP_PASS='jira' \
    -e CROWD_BASE_URL='https://cloudbrocktec.com/crowd' \
    registry.cloudbrocktec.com/atlassian-suite/jira-server-sso:8.12.1
```

### Environment Variables
| Variable Name | Description | Default Value |
| --- | --- | --- |
| ATL_TOMCAT_PORT | The port jira listens on, this may need to be changed depending on your environment. | 8080 |
| ATL_TOMCAT_SCHEME | The protocol via which jira is accessed | http |
| ATL_TOMCAT_SECURE | Set to true if `ATL_TOMCAT_SCHEME` is 'https' | false |
| ATL_TOMCAT_CONTEXTPATH | The context path the application is served over | None |
| ATL_PROXY_NAME | The reverse proxys full URL for jira | None |
| ATL_PROXY_PORT | The reverse proxy's port number | None |
| CUSTOM_SSO_LOGIN_URL | Login URL for Custom SSO Support | None |
| CROWD_SSO_ENABLED | Enable Crowd SSO Support | false |
| CROWD_APP_NAME | Crowd Application Name, Required if for Crowd SSO. | None |
| CROWD_APP_PASS | Crowd Application Password, Required if for Crowd SSO. | None |
| CROWD_BASE_URL | Crowd's Base URL | None |
| JVM_MINIMUM_MEMORY | Set's Java XMS | None |
| JVM_MAXIMUM_MEMORY | Set's Java XMX | None |