#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

result=""
until [[ $result -eq 200 ]] ; do
    sleep 1
    result=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5000/api/health_check)
done

echo "=> Huskar API is ready, starting nginx..."
exec /usr/sbin/nginx -g 'daemon off;'
