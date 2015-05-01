#!/bin/bash

scriptDir=`dirname "$0"`
DEFAULTHAJPTESTJAR=../target/hajp-test.jar

function log {
    DATE='date +%H:%M:%S'
    echo `$DATE`" $1"
}

function usage {
         echo "Usage: runScript.sh [options]"
         echo ""
         echo "Options:"
         echo "--runtests (optional) : Once docker containers are running, execute the hajp-test suite"
         echo "--testjar <location of hajp-test.jar (optional) : Defaults to $DEFAULTHAJPTESTJAR"
         echo "--coreversion <version> (optional) : version of core to use (leave empty for latest release, or specify SNAPSHOT)"
         echo "--monitorversion <version> (optional) : version of monitor to use (leave empty for latest release, or specify SNAPSHOT)"
         echo "--orchestratorversion <version> (optional) : version of orchestrator to use (leave empty for latest release, or specify SNAPSHOT)"
         echo "--verbose : enable verbose logging"
}

TEMP=`getopt -o v --long verbose,help,runtests,testjar:,coreversion:,monitorversion:,orchestratorversion: \
             -n 'runScript.sh' -- "$@"`

if [ $? != 0 ] ; then log "Exiting..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

runTests=
while true; do
  case "$1" in
    --verbose) set -x ; shift;;
    --runtests ) runTests=true; shift ;;
    --testjar ) HAJPTESTJAR="$2"; shift 2 ;;
    --monitorversion ) monitorVersion="$2"; shift 2 ;;
    --orchestratorversion ) orchestratorVersion="$2"; shift 2 ;;
    --coreversion ) coreVersion="$2"; shift 2 ;;
    --help) usage; exit 1 ; shift;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

log ""
log "-------------------------------------"
log "- HAJP Test Run Script              -"
log "-------------------------------------"
log ""

if [ -z "$HAJPTESTJAR" ]; then
  HAJPTESTJAR="$DEFAULTHAJPTESTJAR"
fi

if [ ! -z "$runTests" ]; then
  if [ ! -f "$HAJPTESTJAR" ]; then
    log "Error: HAJP Test jar $HAJPTESTJAR does not exist!"
    exit 1
  fi
  log "Will use HAJP Test Jar => $HAJPTESTJAR"
fi

dockerregistry=armdocker.rnd.ericsson.se
project=proj_hajp
orchestratorSubProject=orchestrator
monitorSubProject=monitor
coreSubProject=core

USERPASSWD=artread:AP521Mum3bXTzW7M8YtAY2iCJ9u
GROUP=com.ericsson.jenkinsci.hajp
REPO=proj-jnkserv-staging-local
ROOTURL=https://arm.mo.ca.am.ericsson.se/artifactory/api/search/versions

coreI+=$coreSubProject
coreI+=1
coreII+=$coreSubProject
coreII+=2


log "* Verifying versions to use..."
if [ -z "$orchestratorVersion" ] ; then
  log "  Will use Latest Release Version of Orchestrator"
  orchestratorVersion=`curl -s --user $USERPASSWD "$ROOTURL?g=$GROUP&a=hajp-orchestrator_2.11&repos=$REPO" | grep version | cut -f2 -d: | cut -f2 -d\" | head -1`
fi
if [ -z "$orchestratorVersion" ] ; then
  log "Error: Could not find latest version of orchestrator"
  exit 1
fi

if [ -z "$monitorVersion" ] ; then
  log "  Will use Latest Release Version of Monitor"
  monitorVersion=`curl -s --user $USERPASSWD "$ROOTURL?g=$GROUP&a=hajp-monitor_2.11&repos=$REPO" | grep version | cut -f2 -d: | cut -f2 -d\" | head -1`
fi
if [ -z "$monitorVersion" ] ; then
  log "Error: Could not find latest version of monitor"
  exit 1
fi

if [ -z "$coreVersion" ] ; then
  log "  Will use Latest Release Version of Core"
  coreVersion=`curl -s --user $USERPASSWD "$ROOTURL?g=$GROUP&a=hajp-core&repos=$REPO" | grep version | cut -f2 -d: | cut -f2 -d\" | head -1`
fi
if [ -z "$coreVersion" ] ; then
  log "Error: Could not find latest version of core"
  exit 1
fi

log ""
log "   --> orchestratorVersion=$orchestratorVersion"
log "   --> monitorVersion=$monitorVersion"
log "   --> coreVersion=$coreVersion"
log ""

export http_proxy=
export https_proxy=

log ""
log "* Unpausing docker containers"
docker unpause $orchestratorSubProject
docker unpause $monitorSubProject
docker unpause $coreI
docker unpause $coreII

log ""
log "* Killing docker containers"
docker kill $orchestratorSubProject $monitorSubProject $coreI $coreII

# First remove all named containers
log ""
log "* Removing docker containers"
docker rm -f $orchestratorSubProject
docker rm -f $monitorSubProject
docker rm -f $coreI
docker rm -f $coreII

log ""
log "* Start Orchestrator"
# Launch Orchestrator First
CMD="docker run -v /etc/localtime:/etc/localtime:ro -d --name $orchestratorSubProject $dockerregistry/$project/$orchestratorSubProject:$orchestratorVersion"
log "  with: $CMD"
$CMD

orchestratorIP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $orchestratorSubProject`

log ""
log "* Start Monitor"
CMD="docker run -v /etc/localtime:/etc/localtime:ro -d --name $monitorSubProject -p 9000:9000 --link $orchestratorSubProject:$orchestratorSubProject $dockerregistry/$project/$monitorSubProject:$monitorVersion"
log "  with: $CMD"
$CMD

log ""
log "* Start Core1"
CMD="docker run -v /etc/localtime:/etc/localtime:ro -d --name $coreI  -p 9080:8080 --link $orchestratorSubProject:$orchestratorSubProject $dockerregistry/$project/$coreSubProject:$coreVersion"
log "  with: $CMD"
$CMD

log ""
log "* Start Core2"
CMD="docker run -v /etc/localtime:/etc/localtime:ro -d --name $coreII  -p 9081:8080 --link $orchestratorSubProject:$orchestratorSubProject $dockerregistry/$project/$coreSubProject:$coreVersion"
log "  with: $CMD"
$CMD

core1IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $coreI`
core2IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $coreII`
monitorIP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $monitorSubProject`

log ""
log "* Docker Summary"
log " --> Set Self IP of CoreI (port 9080) to $core1IP with port 2551"
log " --> Set Self IP of Core2 (port 9081) to $core2IP with port 2551"
log " --> Orchestrator IP is $orchestratorIP with port 2551"
log " --> Monitor IP is $monitorIP with port 2551"

log ""
log "Sleeping to allow containers to spin up..."
UP=
for i in `seq 1 30`
do
  SITESTATUS="`curl --noproxy '*' -S -s --head $core1IP:8080 | head -1 | tr -d '\n' | tr -d '\r'`"
  if echo $SITESTATUS | grep -q 'HTTP/1.1 200 OK' ; then
    log "CORE1 ($core1IP:8080) is up!"
    UP=1
    break
  else
    sleep 10
  fi
done

if [ -z "$UP" ]; then
  log "CORE1 did not come up at $core1IP:8080"
  exit 1
fi

log ""
log "-----------------------"
if [ ! -z "$runTests" ]; then
  log " Running tests with this:"
  log " java -jar $HAJPTESTJAR --orchestrator $orchestratorIP:2551 --monitor $monitorIP:2551 --core1 $core1IP:2551 --core2 $core2IP:2551"
  log "-----------------------"
  log ""
  java -jar $HAJPTESTJAR --orchestrator $orchestratorIP:2551 --monitor $monitorIP:2551 --core1 $core1IP:2551 --core2 $core2IP:2551
  if [ $? -ne 0 ] ; then
    exit 1
  fi
else
  log " You may now run tests as follows:"
  log " java -jar $HAJPTESTJAR --orchestrator $orchestratorIP:2551 --monitor $monitorIP:2551 --core1 $core1IP:2551 --core2 $core2IP:2551"
  log "-----------------------"
fi
log ""



