Feature: Cluster configuration persistence
  HAJP cluster configuration is persisted once submitted

  Scenario: User should be able to manipulate cluster configuration in HAJP Settings
    Given HAJP plugin is installed on Jenkins instance
    When a user navigates to the HAJP Settings page
    Then cluster configurations should be displayed if pre-configured
    And a Submit button for joining or reconnecting the cluster
    And a Clear button for clearing the cluster configurations
    And a Disconnect button for disconnecting from the cluster
    And a Leave button  button for leaving the cluster
    And an Auto-Reconnect checkbox for enabling/disabling automatic reconnection
