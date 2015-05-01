#!/bin/bash

rm temp/*.hpi
rm temp/*.jar
rm temp/*.zip
rm jenkins.war

PASSWORD='\{DESede\}YNtyA/TMlbuQjz/BlYj9Pw=='
USERNAME=artread
JENKINSVERSION=1.580.2

# Download core plugin
wget -O WEB-INF/plugins/hajp-core.hpi --user=$USERNAME --password=$PASSWORD https://arm.mo.ca.am.ericsson.se/artifactory/simple/proj-jnkserv-staging-local/com/ericsson/jenkinsci/hajp/hajp-core/2.0.0/hajp-core-2.0.0.hpi

# Download jquery plugin
wget -O WEB-INF/plugins/jquery.hpi https://updates.jenkins-ci.org/latest/jquery.hpi -o WEB-INF/plugins/jquery.hpi

# Download monitor
wget -O temp/hajp-monitor.zip --user=$USERNAME --password=$PASSWORD https://arm.mo.ca.am.ericsson.se/artifactory/simple/proj-jnkserv-dev-local/com/ericsson/jenkinsci/hajp/hajp-monitor_2.11/1.0.0/hajp-monitor_2.11-1.0.0.zip

# Download orchestrator
wget -O temp/hajp-orchestrator-assembly.jar --user=$USERNAME --password=$PASSWORD https://arm.mo.ca.am.ericsson.se/artifactory/simple/proj-jnkserv-dev-local/com/ericsson/jenkinsci/hajp/hajp-orchestrator_2.11/1.0.0/hajp-orchestrator_2.11-1.0.0-assembly.jar

# Download jenkins.war
wget https://updates.jenkins-ci.org/download/war/$JENKINSVERSION/jenkins.war

# Add needed jars and plugin to Jenkins.war
zip --grow jenkins.war WEB-INF/plugins/*
zip --grow jenkins.war WEB-INF/lib/*

# remove all unnecessary files

