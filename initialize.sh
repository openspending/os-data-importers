#!/bin/sh
set -e

npm install -g moment underscore lodash lodash-addons bluebird superagent
npm install -g os-types

ls -la /usr/lib/node_modules
rm celerybeat-schedule || ls -la
pwd
cd eu-structural-funds
export PYTHONPATH=$PYTHONPATH:`pwd`
export DATAPIPELINES_PROCESSOR_PATH=`pwd`/common/processors
pip3 install -r requirements.txt
pip3 install -U git+git://github.com/openspending/datapackage-pipelines-fiscal.git
pip3 install -U git+git://github.com/frictionlessdata/datapackage-pipelines.git
pip3 install -U git+git://github.com/openspending/gobble.git
pip3 install -U git+git://github.com/frictionlessdata/tabulator-py.git
python3 -m common.generate
cd ..
dpp init
dpp
python3 -m celery -b amqp://guest:guest@mq:5672// --concurrency=4 -B -A datapackage_pipelines.app -Q datapackage-pipelines -l INFO worker &
dpp serve
