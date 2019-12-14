# -*- coding: utf-8 -*-

import json
import os

from kazoo.client import KazooClient

client = KazooClient()
client.start()

ZK_PREFIX = '/huskar/config/huskar.api'
INFRA_APP_ID_LIST = [
    'dal.huskar_api',
    'dal.demo',
    'redis.huskar_api',
    'redis.demo',
    'amqp.demo',
    'es.demo',
    'mongo.demo',
    'oss.demo',
    'kafka.demo',
]
EZONE = os.environ.get('HUSKAR_API_EZONE', 'alta1')
EZONE_LIST = os.environ.get('HUSKAR_EZONE_LIST', '').split(',')
EZONE_LIST = [x for x in EZONE_LIST if x != 'global']
IDC_LIST = os.environ.get('HUSKAR_IDC_LIST', '').split(',')
IDC_LIST = [x for x in IDC_LIST if x not in EZONE_LIST]


client.ensure_path(ZK_PREFIX + '/overall/ROUTE_IDC_LIST')
client.ensure_path(ZK_PREFIX + '/overall/ROUTE_EZONE_LIST')
client.set(ZK_PREFIX + '/overall/ROUTE_IDC_LIST', json.dumps(IDC_LIST))
client.set(ZK_PREFIX + '/overall/ROUTE_EZONE_LIST', json.dumps(EZONE_LIST))

client.ensure_path(ZK_PREFIX + '/overall/ROUTE_EZONE_DEFAULT_HIJACK_MODE')
for ezone in EZONE_LIST:
    client.set(ZK_PREFIX + '/overall/ROUTE_EZONE_DEFAULT_HIJACK_MODE',
               json.dumps({x: 'S' for x in EZONE_LIST}))

client.ensure_path(ZK_PREFIX + '/overall/FX_DATABASE_SETTINGS')
client.set(ZK_PREFIX + '/overall/FX_DATABASE_SETTINGS', json.dumps({
    'idcs': {
        EZONE: {
            'default': {
                'master': os.environ['DATABASE_DEFAULT_URL'],
                'slave': os.environ['DATABASE_DEFAULT_URL'],
            },
        },
    },
}))
client.ensure_path(ZK_PREFIX + '/overall/FX_REDIS_SETTINGS')
client.set(ZK_PREFIX + '/overall/FX_REDIS_SETTINGS', json.dumps({
    'idcs': {
        EZONE: {
            'default': {
                'url': os.environ['REDIS_DEFAULT_URL'],
            },
        },
    },
}))

for app_id in INFRA_APP_ID_LIST:
    for ezone in EZONE_LIST:
        path = '/huskar/service/%s/overall.%s/192.168.0.1_5000' % (
                app_id, ezone)
        client.ensure_path(path)
        client.set(path, json.dumps({
            'ip': '192.168.0.1',
            'port': {
                'main': 5000,
            },
            'meta': {
                'host': 'example.com',
            },
            'state': 'up',
        }))
