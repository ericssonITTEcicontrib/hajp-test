Feature: HAJP cluster must be using the same credentials and secrets for active master and
  all hot standby members.

  @CredentialsSync
  Scenario: active master secrets must be synchronized and usable
  when a Jenkins instance attempts to join as hot standby
    Given: active master exists in the cluster
    And: joining Jenkins instance does not have the same master key and secrets as active master
    When: I attempt to join a Jenkins instance as hot standby
    Then: hot standby Jenkins instance master key and secrets are replaced
  with active master master key and secrets
    And: hot standby Jenkins instance is restarted

  @CredentialsSync
  Scenario: active master credentials must be initially synchronized and made usable
  on hot standby join.
    Given: active master exists in the cluster
    And: joining Jenkins instance has the same master key and secrets as active master
    When: I add another Jenkins instance as hot standby
    Then: hot standby Jenkins instance receives all credentials of active master
    And: received hot standby credentials are usable by plugins and jobs in an identical
  manner to active master credentials.

  @CredentialsSync
  Scenario: active master credentials must be synchronized and usable
  when a new credentials is added on active master.
    Given: active master exists in the cluster
    And: hot standby exists in the cluster
    When: I add a new credential on active master
    Then: the same credential is synced to hot standby Jenkins instance
    And: after hot-standby restarts
    And: received hot standby credentials are usable by plugins and jobs in an identical
  manner to active master credentials.

  @CredentialsSync
  Scenario: active master credentials must be synchronized and usable
  when an existing credential is updated on active master.
    Given: active master exists in the cluster
    And: hot standby exists in the cluster
    When: I modify an existing credential on active master
    Then: the same credential is updated on hot standby Jenkins instance
    And: after hot-standby restarts
    And: received hot standby credentials are usable by plugins and jobs in an identical
  manner to active master credentials.

  @CredentialsSync
  Scenario: active master credentials must be synchronized and usable
  when an existing credential is deleted on active master.
    Given: active master exists in the cluster
    And: hot standby exists in the cluster
    When: I deleted an existing credential on active master
    Then: the same credential is removed from hot standby Jenkins instance
    And: after hot-standby restarts
    And: received hot standby credentials are usable by plugins and jobs in an identical
  manner to active master credentials.
