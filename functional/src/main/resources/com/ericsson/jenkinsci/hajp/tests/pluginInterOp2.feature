Feature: Basic functions of top Jenkins plugins work well with HAJP cluster (continued with pluginInterOp.feature), and
  HS is aware of job level configuration changes.
  Global settings of Jenkins and non-job level settings of related plugins are synced manually.
  AM - Jenkins Active Master instance, HS - one or more Jenkins Hot Standby instances, Orchestrator - One Orchestrator instance.
  AM leaves the cluster - AM is restarted.

  #already installed by default
  @SSHSlavePlugin
  Scenario:  Project configurations related to SSH Slave Plugin should work upon failover
    Given a project P on AM
    And there is a master node and a slave node on both AM and HS
    And the slave node is configured with the correct credentials
    And project P is configured to execute on the slave node of AM
    When AM leaves the cluster
    Then The jobs of P are performed on the slave node of HS

  #already installed by default
  @todo right now only focus on freestyle projects
  @MavenProjectPlugin
  Scenario:  Configurations of a maven project should work upon failover
    Given a maven project P on AM
    When AM leaves the cluster
    Then the jobs of P are performed on HS

  @todo
  @MavenProjectPlugin
  Scenario:  Changes on configurations of a maven project should be aware upon failover
    Given a maven project P on AM
    And configure the maven goal "clean test"
    And build P
    When change the maven goal to "clean package"
    And AM leaves the cluster
    Then the jobs of P are performed with the goal "clean package" on HS

  @EmailExtPlugin
  Scenario:  Project configurations related to Email Ext Plugin should work upon failover
    Given a project P on AM
    And project P is configured with "sending email notification" when P is built
    When AM leaves the cluster
    Then the email notifications are sent on HS when P is built

  @EmailExtPlugin
  Scenario:  Changes on configurations of a project should be aware upon failover
    Given a project P on AM
    And project P is configured with "sending email notification" when P is built
    And project P is configured with Recipient List RL1
    And a build of P is performed
    When recipient list is changed to PL2
    And AM leaves the cluster
    Then email notifications are sent to PL2 on HS when P is built

  @BuildPipelinePlugin
  Scenario:  Project configurations related to Build Pipeline Plugin should work upon failover
    Given projects P1, P2, P3 on AM
    And create Build Pipeline View V on both AM and HS with the initial job P1
    And project P1 is configured to trigger P2 and P3
    When AM leaves the cluster
    Then V can show the build pipeline view on HS

  @BuildPipelinePlugin
  Scenario:  Changes on configurations of a project should be aware upon failover
    Given projects P1, P2, P3 on AM
    And create Build Pipeline View V on both AM and HS with the initial job P1
    And project P1 is configured to trigger P2
    And a build of P1 is performed
    When project P1 is configured to trigger P2 and P3
    And AM leaves the cluster
    Then V can show the build pipeline with P1, P2, and P3 on HS when P1 is built

  #currently the data related to Job ConfigHistory Plugin are not synced
  @todo
  @JobConfigHistoryPlugin
  Scenario:  Job config history should work upon failover
    Given project P on AM
    And change configuration of P to get a history H of job configurations
    When AM leaves the cluster
    Then H can be shown on HS

  @todo
  @JobConfigHistoryPlugin
  Scenario:  Changes on job configuration history of a project should be aware upon failover
    Given project P on AM
    And change configuration of P to get a history of job configurations
    When roll back the configuration of P to the initial status
    And AM leaves the cluster
    Then the configuration of P is in the initial status on HS
