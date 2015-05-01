#! /bin/bash
cd ..
APP_HOME=$(cd "$(dirname "$0")"; pwd)

java -jar hajp-test.jar  --deploy $APP_HOME/deploy
