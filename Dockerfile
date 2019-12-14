FROM centos:7

RUN rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -i https://centos7.iuscommunity.org/ius-release.rpm && \
    rpm -i https://rpm.nodesource.com/pub_8.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm && \
    yum install -y curl && \
    curl https://www.apache.org/dist/bigtop/stable/repos/centos7/bigtop.repo \
        > /etc/yum.repos.d/bigtop.repo && \
    yum install -y sudo \
        gcc \
        gcc-c++ \
        git \
        java \
        redis \
        zookeeper \
        mariadb101u-server \
        nginx \
        nodejs \
        libsass-devel \
        python \
        python-devel\
        python-pip \
        supervisor

RUN pip install -U pip virtualenv && \
    sudo -u mysql /usr/libexec/mysql-prepare-db-dir
ENV SUPERVISOR 1

WORKDIR /srv/huskar_api/
RUN git clone https://github.com/huskar-org/huskar.git . && \
    git checkout v0.242.4 && \
    rm -rf .git

WORKDIR /srv/huskar_api/
RUN virtualenv /opt/huskar_api && \
    /opt/huskar_api/bin/pip install -r requirements.txt

WORKDIR /srv/huskar_console/
RUN git clone https://github.com/huskar-org/huskar-console.git . && \
    git checkout v0.174.2 && \
    rm -rf .git

WORKDIR /srv/huskar_console/
ENV HUSKAR_API_URL http://127.0.0.1/api
ENV HUSKAR_FEATURE_LIST createapp,stateswitch,infrarawurl
ENV HUSKAR_EZONE_LIST global,alta1,altb1
ENV HUSKAR_IDC_LIST alta,altb
ENV HUSKAR_ROUTE_EZONE_CLUSTER_LIST alta1:alta1-test,altb1:altb1-test
RUN npm install && \
    NODE_ENV=production npm run build && \
    rm -rf ./node_modules/

WORKDIR /srv/
ENV GEVENT_RESOLVER block
ENV HUSKAR_API_APP_NAME huskar.api
ENV HUSKAR_API_ADMIN_FRONTEND_NAME huskar.console
ENV HUSKAR_API_TESTING 1
ENV HUSKAR_API_SECRET_KEY all-in-one
ENV HUSKAR_API_EZONE alta1
ENV HUSKAR_API_CLUSTER alta1-test
ENV HUSKAR_API_DB_URL mysql+pymysql://root@localhost/huskar_api?charset=utf8mb4
ENV DATABASE_DEFAULT_URL mysql://root@localhost/huskar_api?charset=utf8mb4
ENV HUSKAR_API_REDIS_URL redis://localhost:6379/0
ENV REDIS_DEFAULT_URL redis://localhost:6379/0
ENV HUSKAR_API_ZK_SERVERS 127.0.0.1:2181

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d /etc/nginx/conf.d
COPY supervisord.d /etc/supervisord.d
COPY scripts/entrypoint_api.sh /opt/huskar_api/bin/entrypoint.sh
COPY scripts/init-cfg.py /opt/huskar_api/bin/init-cfg.py
RUN chmod +x /opt/huskar_api/bin/entrypoint.sh
COPY scripts/entrypoint_console.sh /opt/huskar_console/bin/entrypoint.sh
RUN chmod +x /opt/huskar_console/bin/entrypoint.sh
RUN mkdir -p /var/log/huskar_api

EXPOSE 80

CMD ["supervisord", "--nodaemon"]
