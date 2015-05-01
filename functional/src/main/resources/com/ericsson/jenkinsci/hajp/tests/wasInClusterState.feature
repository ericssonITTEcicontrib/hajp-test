Feature: WasInCluster state behavior
  expected behavior when cluster state is WasInCluster

  Scenario: WasInCluster instance should block and discard queued builds
    Given a Jenkins instance is in WasInCluster state
    When a new item is added to the queued
    Then this item should be blocked from executing due to current state
    And this item should be removed from the queue

  Scenario: Leaving the cluster puts the instance in NotInCluster state
    Given a Jenkins instance is in WasInCluster state
    When a user invokes Leaving the cluster
    Then the instance should leave the cluster
    And the instance should be in NotInCluster state

  Scenario: Reconnecting an instance puts the instance in InCluster state
    Given a Jenkins instance is in WasInCluster state
    When a user invokes Reconnecting the cluster
    Then the instance should reconnect the cluster
    And the instance should be in InCluster state
