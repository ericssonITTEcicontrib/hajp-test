#!/bin/bash

PASSWORD='\{DESede\}YNtyA/TMlbuQjz/BlYj9Pw=='
USERNAME=artread
JENKINSVERSION=1.596.2

# Download core plugin
wget -O WEB-INF/plugins/hajp-core.hpi --user=$USERNAME --password=$PASSWORD https://arm.mo.ca.am.ericsson.se/artifactory/simple/proj-jnkserv-staging-local/com/ericsson/jenkinsci/hajp/hajp-core/2.0.2/hajp-core-2.0.2.hpi

# Download jquery plugin
wget -O WEB-INF/plugins/jquery.hpi https://updates.jenkins-ci.org/latest/jquery.hpi

# Download monitor
wget -O temp/hajp-monitor.zip --user=$USERNAME --password=$PASSWORD https://arm.mo.ca.am.ericsson.se/artifactory/simple/proj-jnkserv-staging-local/com/ericsson/jenkinsci/hajp/hajp-monitor_2.11/1.0.5/hajp-monitor_2.11-1.0.5.zip

# Download orchestrator
wget -O temp/hajp-orchestrator-assembly.jar --user=$USERNAME --password=$PASSWORD https://arm.mo.ca.am.ericsson.se/artifactory/simple/proj-jnkserv-staging-local/com/ericsson/jenkinsci/hajp/hajp-orchestrator_2.11/1.0.7/hajp-orchestrator_2.11-1.0.7-assembly.jar

# Download jenkins.war
wget -O jenkins.war --user=$USERNAME --password=$PASSWORD https://arm.mo.ca.am.ericsson.se/artifactory/simple/proj-jnkserv-staging-local/com/ericsson/jenkinsci/hajp/hajp-core/2.0.2/hajp-core-2.0.2-jenkins-war-modified.war

# Add needed jars and plugin to Jenkins.war
zip --grow jenkins.war WEB-INF/plugins/*

# remove all unnecessary files
