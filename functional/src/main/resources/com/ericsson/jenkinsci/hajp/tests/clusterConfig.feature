Feature: HAJP cluster must be configurable via plugin, orchestrator and frontend
    to allow ease of deployment

  @Plugin
  Scenario: HAJP plugin must be configurable as to its own and seed IP
    Given: Jenkins is running
    When: I set own IP and seed IP config from front-end
    Then: Joins cluster as a jenkins role member

  @Plugin
  Scenario: HAJP plugin must not join cluster if its own or seed IP
    is not configured
    Given: Jenkins is running
    When: I do not set own IP or seed IP config from front-end
    Then: Jenkins does not join cluster as a jenkins role member

  @Orchestrator
  Scenario: HAJP orchestrator must not join cluster if its own IP is not setup
    Given: I do not set own IP from its config file
    When: Orchestrator is launched
    Then: Orchestrator exits stating that its own IP is not correctly configured

  @Orchestrator
  Scenario: HAJP orchestrator must join cluster if its own IP is setup
    Given: I set own IP from its config file
    When: Orchestrator is launched
    Then: Orchestrator exits stating that its own IP is not correctly configured

  @Monitor
  Scenario: HAJP orchestrator must not join cluster if its own IP or seed ip is not setup
    Given: I do not set own IP or seed IP from its frontend
    When: Monitor is launched
    And: dashboard is activated
    Then: Monitor states that its own IP or seed is not correctly configured therefore
    it can not monitor the cluster

  @Monitor
  Scenario: HAJP monitor must join cluster if its own IP and seed ip is setup
    Given: I set own IP or seed IP from its frontend
    When: Monitor is launched
    And: dashboard is activated
    Then: Monitor starts monitoring cluster status
