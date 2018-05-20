#!/bin/sh
set -e

rm celerybeat-schedule || ls -la
cd eu-structural-funds
export PYTHONPATH=$PYTHONPATH:`pwd`
export DPP_PROCESSOR_PATH=`pwd`/common/processors
# python3 -m common.generate
cd ..

export DPP_REDIS_HOST=redis
export CELERY_BROKER=redis://localhost:6379/6
echo "Starting Server"
redis-server /etc/redis.conf --daemonize yes --dir /var/redis
until [ `redis-cli ping | grep -c PONG` = 1 ]; do echo "Waiting 1s for Redis to load"; sleep 1; done


rm -f celeryd.pid
rm -f celerybeat.pid
dpp init
SCHEDULER=1 python3 -m celery -b $CELERY_BROKER -A datapackage_pipelines.app -l INFO beat &
python3 -m celery -b $CELERY_BROKER --concurrency=1 -A datapackage_pipelines.app -Q datapackage-pipelines-management -l INFO worker &
python3 -m celery -b $CELERY_BROKER --concurrency=4 -A datapackage_pipelines.app -Q datapackage-pipelines -l INFO worker &
/usr/bin/env os-types "[]" | true
dpp serve
