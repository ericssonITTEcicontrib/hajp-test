Feature: Disconnect and Restart an instance
  instance restart or disconnect should result in WasInCluster state unless auto-reconnecting to InCluster state

  Scenario: Disconnecting an instance from the cluster puts it in WasInCluster state
    Given the Jenkins instance is in InCluster state
    And a user navigates to HAJP Settings page
    When the Disconnect button is clicked
    Then the Jenkins instance should be removed from the cluster
    And the Jenkins instance should be in WasInCluster state

  Scenario: Restarting an instance that was in InCluster state puts it in WasInCluster state if Auto-Reconnect is disabled
    Given the Jenkins instance is in InCluster state
    And Auto-Reconnect is disabled
    And the Jenkins instance is restated
    When the Jenkins becomes available
    Then the Jenkins instance should be in WasInCluster state

  Scenario: Restarting an instance that was in InCluster state puts it in InCluster state if Auto-Reconnect is enabled
    Given the Jenkins instance is in InCluster state
    And Auto-Reconnect is enabled
    And the Jenkins instance is restated
    When the Jenkins becomes available
    Then the Jenkins instance should reconnect the cluster with its previous settings
    And the Jenkins instance should be in InCluster state
