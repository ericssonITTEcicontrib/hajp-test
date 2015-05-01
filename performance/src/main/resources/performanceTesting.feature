Feature: Standardized set of performance tests designed to give basic benchmark of HAJP performance.
  AM stands for active master.
  HS stands for hot standby.

  Scenario: Create 50 jobs across cluster
    Given: there is an active master
    And: there is a hot standby
    When: I create 50 new jobs in active master
    Then: then I see 50 jobs in hot standby after 30 seconds

  Scenario: Create 500 builds across cluster
    Given: there is an active master
    And: there is a hot standby
    And: there are 50 identical jobs on AM and HS
    When: I create 10 builds on each AM job
    Then: then I see all 500 jobs in hot standby after 30 seconds
