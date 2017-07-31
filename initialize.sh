#!/bin/sh
set -e

npm install -g moment underscore lodash lodash-addons bluebird superagent
npm install -g os-types

ls -la /usr/lib/node_modules
rm celerybeat-schedule || ls -la
pwd
cd eu-structural-funds
export PYTHONPATH=$PYTHONPATH:`pwd`
export DPP_PROCESSOR_PATH=`pwd`/common/processors
pip3 install -r requirements.txt
pip3 install -U git+git://github.com/openspending/datapackage-pipelines-fiscal.git
pip3 install -U git+git://github.com/frictionlessdata/datapackage-pipelines.git
#pip3 install -U git+git://github.com/openspending/gobble.git
#pip3 install -U git+git://github.com/frictionlessdata/tabulator-py.git
python3 -m common.generate
cd ..
rm -f celeryd.pid
rm -f celerybeat.pid
dpp init
python3 -m celery -b amqp://guest:guest@mq:5672// -A datapackage_pipelines.app -l INFO beat &
python3 -m celery -b amqp://guest:guest@mq:5672// --concurrency=1 -A datapackage_pipelines.app -Q datapackage-pipelines-management -l INFO worker &
python3 -m celery -b amqp://guest:guest@mq:5672// --concurrency=4 -A datapackage_pipelines.app -Q datapackage-pipelines -l INFO worker &
/usr/bin/env os-types "[]" | true
dpp serve
