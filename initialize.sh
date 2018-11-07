#!/bin/sh
set -e

# Set up pipelines scheduler only if $OS_DPP_DISABLE_PIPELINES is not True
if [[ -n "$OS_DPP_DISABLE_PIPELINES" && "$OS_DPP_DISABLE_PIPELINES" = "True" ]]; then
    echo "Pipelines are disabled."
    dpp init
else
    echo "Starting Celery schedulers"
    rm -f celeryd.pid
    rm -f celerybeat.pid

    # Reset pipeline statuses
    redis-cli -h $DPP_REDIS_HOST -n 5 FLUSHDB

    SCHEDULER=1 python3 -m celery -b $DPP_CELERY_BROKER -A datapackage_pipelines.app -l INFO beat &
    python3 -m celery -b $DPP_CELERY_BROKER --concurrency=1 -A datapackage_pipelines.app -Q datapackage-pipelines-management -l INFO worker -n worker1@%h &
    python3 -m celery -b $DPP_CELERY_BROKER --concurrency=4 -A datapackage_pipelines.app -Q datapackage-pipelines -l INFO worker -n worker2@%h &
    /usr/bin/env os-types "[]" | true
fi

# Always run the dpp server, even if pipelines are disabled. This is so the
# container can respond to web requests.
cd source-specs
dpp serve
