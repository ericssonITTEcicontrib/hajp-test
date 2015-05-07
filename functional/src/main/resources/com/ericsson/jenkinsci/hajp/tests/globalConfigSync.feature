Feature: Global configurations of Jenkins are synchronized in HAJP cluster.
  AM - Jenkins Active Master instance, HS - one or more Jenkins Hot Standby instances, Orchestrator - One Orchestrator instance.
  AM leaves the cluster - AM is restarted.

  @GlobalConfigSync
  Scenario:  HS is aware of global configuration changes.
    Given a global configuration, System Message, is set up on AM with value V1
    When change V1 on AM to another value V2
    Then "System Message" on HS is with value V2

  @GlobalConfigSync
  Scenario:  Changes on environment variables should take effect upon failover
    Given The environment variable, myVar, is configurated on AM with value V1 in global properties session
    And a job J is configurated on AM to use myVar
    When change V1 on AM to another value V2
    And AM leaves the cluster
    And a build B of J is performed on HS
    Then V2 is used in B

  @GlobalConfigSync
  Scenario:  Changes on jdk installations should take effect upon failover
    Given The jdk installation, JDK1, is configurated on AM in JDK session
    And a job J is configurated on AM to use JDK1
    When delete JDK1 and install another JDK, JDK2, on AM
    And AM leaves the cluster
    And a build B of J is performed on HS
    Then JDK2 is used in B

  @GlobalConfigSync
  Scenario:  Changes on email notification should take effect upon failover
    Given The SMTP server, S1, is configurated on AM in email notification session
    When change S1 to another SMTP server, S2, on AM
    And AM leaves the cluster
    Then S2 is used to send email on HS
