#!/bin/sh
set -e

while ! ping -c1 redis &>/dev/null
do
  echo "REDIS is DOWN"
  sleep 1
done
echo "REDIS is UP"

while ! ping -c1 mq &>/dev/null
do
  echo "MQ is DOWN"
  sleep 1
done
echo "MQ is UP"

cd /app

./initialize.sh
