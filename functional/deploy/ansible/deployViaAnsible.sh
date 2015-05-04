#!/bin/bash

./getBinaries.sh

ansible-playbook --inventory=hosts.yml playbook-killall-java.yml
ansible-playbook --inventory=hosts.yml playbook-install-jdk8.yml
ansible-playbook --inventory=hosts.yml playbook-deploy-jenkins.yml
ansible-playbook --inventory=hosts.yml playbook-deploy-orchestratormonitor.yml
ansible-playbook --inventory=hosts.yml playbook-launch-orchestrator.yml
ansible-playbook --inventory=hosts.yml playbook-launch-jenkins.yml
