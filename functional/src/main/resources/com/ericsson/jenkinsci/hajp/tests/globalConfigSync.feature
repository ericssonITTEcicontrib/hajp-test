Feature: Global configurations of Jenkins are synchronized in HAJP cluster.
  AM - Jenkins Active Master instance, HS - one or more Jenkins Hot Standby instances, Orchestrator - One Orchestrator instance.
  AM leaves the cluster - AM is restarted.
  Global configurations of Jenkins are listed below (including sub-entries if applies):
    Workspace Root Directory
    Build Record Root Directory
    System Message
    number of executors
    Labels
    Usage
    Quiet period
    SCM checkout retry count
    Restrict project naming
    Environment variables
    add tool locations
    JDK

  @GlobalConfigSync
  Scenario:  HS is aware of System Message changes.
    Given a global configuration, System Message, is set up on AM with value V1
    When change V1 on AM to another value V2
    Then "System Message" on HS is with value V2

  @GlobalConfigSync
  Scenario:  Changes on System Message should take effect upon failover
    Given a global configuration, System Message, is set up on AM with value V1
    When change V1 on AM to another value V2
    And AM leaves the cluster
    Then V2 is used on the top page on HS

  @GlobalConfigSync
  Scenario:  HS is aware of environment variable changes.
    Given a global configuration, environment variable E, is set up on AM with value V1
    When change V1 on AM to another value V2
    Then E is with value V2 on HS

  @GlobalConfigSync
  Scenario:  Changes on environment variables should take effect upon failover
    Given The environment variable, myVar, is configurated on AM with value V1 in global properties session
    And a job J is configurated on AM to use myVar
    When change V1 on AM to another value V2
    And AM leaves the cluster
    And a build B of J is performed on HS
    Then V2 is used in B

  @GlobalConfigSync
  Scenario:  HS is aware of jdk installation changes.
    Given a global configuration, jdk installation, is set up on AM with value JDK1
    When change JDK1 on AM to another value JDK2
    Then jdk installation is with value JDK2 on HS

  @GlobalConfigSync
  Scenario:  Changes on jdk installations should take effect upon failover
    Given The jdk installation, JDK1, is configurated on AM in JDK session
    And a job J is configurated on AM to use JDK1
    When delete JDK1 and install another JDK, JDK2, on AM
    And AM leaves the cluster
    And a build B of J is performed on HS
    Then JDK2 is used in B

