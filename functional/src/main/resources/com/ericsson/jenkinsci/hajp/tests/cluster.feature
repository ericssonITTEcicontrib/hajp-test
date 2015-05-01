Feature: cluster ha: join; failover; leave

  @ClusterHAFunctional
  Scenario: cluster join (jenkins) test
    Given jenkins instance 1 has not yet joined the cluster
    And there is an orchestrator
    When click join on jenkins instance 1
    Then jenkins instance 1 joins the cluster

  @ClusterHAFunctional
  Scenario: cluster leave (jenkins) test
    Given jenkins instance 1 has joined the cluster
    And there is an orchestrator
    When jenkins instance 1 is restarted
    Then jenkins instance 1 is not the cluster

  @ClusterHAFunctional
  Scenario: cluster failover (jenkins) test
    Given jenkins instance 1 has the active master role
    And jenkins instance 2 has the hot standby master role
    And there is an orchestrator
    When jenkins instance 1 is restarted
    Then jenkins instance 2 becomes the active master role
