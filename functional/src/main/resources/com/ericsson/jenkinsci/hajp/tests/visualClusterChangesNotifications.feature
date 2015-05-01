Feature: Visual cluster changes notifications
  requirements for UI notification upon cluster changes

  Scenario: User should be notified when the instance's state changes
    Given a Jenkins instance is in state S1
    When the Jenkins instance's state is changed to S2
    Then a short-lived notification on this state change should be shown
    And this notification should be visible in any page

  Scenario: User should be notified when the instance's role changes
    Given a Jenkins instance has a role R1
    When the Jenkins instance's role is changed to R2
    Then a short-lived notification on this state change should be shown
    And this notification should be visible in any page

  Scenario: User should be notified that the instance is in WasInCluster state
    Given the Jenkins instance's state is WasInCluster
    When a user access the instance
    Then a notification on this state should be shown as long as the state is effective
    And this notification should be visible in any page

  Scenario: User should be notified that the instance has a HotStandby role
    Given a Jenkins instance is in InCluster state
    And the Jenkins instance's role is HotStandby
    When a user access the instance
    Then a notification on this role should be shown as long as the state is effective
    And this notification should be visible in any page

  Scenario: User should be notified when a cluster action is imminent (e.g. restarting new HS for credentials sync)
    Given a Jenkins instance is in InCluster state
    When a cluster action is imminent
    Then a notification on this action should be shown until the action is initiated
    And this notification should be visible in any page
