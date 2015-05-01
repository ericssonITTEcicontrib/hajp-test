#!/bin/bash


getIpCmd="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
#orchestratorIP=`vagrant ssh --command $getIpCmd orchestrator`

orchestratorIP=$(eval "vagrant ssh --command \"$getIpCmd orchestrator\"")
core1IP=$(eval "vagrant ssh --command \"$getIpCmd core1\"")
core2IP=$(eval "vagrant ssh --command \"$getIpCmd core2\"")
monitorIP=$(eval "vagrant ssh --command \"$getIpCmd monitor\"")

#echo `vagrant ssh --command $getIpCmd core1`
#core1IP=`vagrant ssh --command docker inspect --format '{{ .NetworkSettings.IPAddress }}' core1`
#core2IP=`vagrant ssh --command docker inspect --format '{{ .NetworkSettings.IPAddress }}' core2`
#monitorIP=`vagrant ssh --command docker inspect --format '{{ .NetworkSettings.IPAddress }}' monitor`

echo -e " "
echo -e " Docker Summary"
echo -e " Set Self IP of Core1 (port 9080) to $core1IP"
echo -e " Set Self IP of Core2 (port 9081) to $core2IP"
echo -e " Orchestrator IP is $orchestratorIP"
echo -e " Monitor IP is $monitorIP"
echo -e " For convenience please use port 2551 for HAJP settings"
