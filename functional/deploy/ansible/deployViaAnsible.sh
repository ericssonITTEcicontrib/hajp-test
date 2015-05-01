#!/bin/bash

./getBinaries.sh

ansible-playbook playbook-killall-java.yml
ansible-playbook playbook-install-jdk8.yml
ansible-playbook playbook-deploy-jenkins.yml
ansible-playbook playbook-deploy-orchestratormonitor.yml
ansible-playbook playbook-launch-orchestrator.yml
ansible-playbook playbook-launch-jenkins.yml
