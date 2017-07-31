#!/bin/sh
set -e

while ! ping -c1 redis &>/dev/null; do :; done && echo "REDIS is UP"
while ! ping -c1 mq &>/dev/null; do :; done && echo "MQ is UP"

cd /app

./initialize.sh
