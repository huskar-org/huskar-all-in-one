#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cd /srv/huskar_api

start() {
    echo "=> Initializing configuration"
    /opt/huskar_api/bin/python /opt/huskar_api/bin/init-cfg.py

    echo "=> Ready"
    exec /opt/huskar_api/bin/gunicorn \
        -c config/gunicorn_config.py huskar_api.wsgi:app
}

echo "=> Checking database"
if [ -n "$(echo 'show databases' | mysql -uroot | grep huskar_api || true)" ]
then
    start
fi

echo "=> Flushing database"
/usr/bin/redis-cli FLUSHALL
/usr/bin/mysql -uroot <<- DONE
CREATE DATABASE huskar_api CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
DONE
/usr/bin/mysql -uroot huskar_api < database/mysql.sql

echo "=> Importing application list"
/usr/bin/mysql -uroot huskar_api <<- DONE
INSERT INTO user (id, username, password, is_active, huskar_admin, is_app)
VALUES (1, 'huskar', '90a3ed9e32b2aaf4c61c410eb925426119e1a9dc53d4286ade99a809',
        1, 1, 0);
INSERT INTO team (id, team_name, team_desc, status)
VALUES (1, 'huskar', 'huskar', 0),
       (2, 'dal', 'dal', 0),
       (3, 'redis', 'redis', 0),
       (4, 'amqp', 'amqp', 0),
       (5, 'es', 'es', 0),
       (6, 'mongo', 'mongo', 0),
       (7, 'oss', 'oss', 0),
       (8, 'kafka', 'kafka', 0);
INSERT INTO application (application_name, team_id, status)
VALUES ('huskar.api', '1', 0),
       ('huskar.console', '1', 0),
       ('dal.huskar_api', '2', 0),
       ('dal.demo', '2', 0),
       ('redis.huskar_api', '3', 0),
       ('redis.demo', '3', 0),
       ('amqp.demo', '4', 0),
       ('es.demo', '5', 0),
       ('mongo.demo', '6', 0),
       ('oss.demo', '7', 0),
       ('kafka.demo', '8', 0);
DONE

start
