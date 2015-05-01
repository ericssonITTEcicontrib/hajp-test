Feature: Basic functions of top plugins works well with HAJP cluster
  Top plugins are aware of system or job level configuration changes when used with HAJP cluster.
  It is assumed that HAJP cluster is configured and synced unless stated otherwise.
  It is assumed that the scenarios annotated with @plugin have the plugin installed on all instances unless stated otherwise.
  AM - Jenkins Active Master instance, HS - one or more Jenkins Hot Standby instances

# Gerrit Trigger scenarios
  @GerritTrigger
  Scenario: Gerrit Trigger is aware when global configuration is changed
    Given AM, HS
    When all fields in Gerrit Trigger's global configuration are assigned new valid values on AM
    And changes are saved
    Then these changes are replicated on HS accordingly

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when a Gerrit server is created
    Given AM, HS
    When a Gerrit server S is created on AM
    Then S is created on HS

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when a Gerrit server is changed
    Given AM, HS, Gerrit server S
    When all fields and sub-fields for S are assigned new valid values on AM
    And changes are saved
    Then these changes are replicated on HS accordingly

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when a Gerrit server is deleted
    # requires 2 gerrit servers since once a gerrit server is set the plugin prevents deleting the last one
    Given AM, HS, Gerrit server S1, Gerrit server S2
    When S1 is deleted on AM
    Then only S1 is deleted on HS

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when a job's Gerrit trigger configuration is changed
    Given AM, HS, job X
    And X has Gerrit trigger configurations
    When all fields and sub-fields of X's Gerrit trigger configuration are assigned with new valid values on AM
    And changes are saved
    Then these changes are replicated on HS accordingly

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when Gerrit server is changed upon fail-over
    Given AM, HS, Gerrit server S, project P, job X
    And S is configured as the only server
    And P exists on S
    And a "Gerrit event" is configured as a trigger on X
    And P is configured as a "Gerrit Project" of X
    And X is configured to trigger upon Patchset Created on P
    When Gerrit server's connection settings given incorrect values on AM
    And Gerrit server's settings are saved
    And Gerrit server is restarted on HS
    And AM is safely exited
    And a new Patchset PS is created on P in S
    Then S's connection should be down no HS
    And no build of X should be triggered due to PS on HS

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when "Gerrit event" is added as build trigger on a job upon fail-over
    Given AM, HS, project P, job X
    When a "Gerrit event" is added as a build trigger to X on AM
    And P is configured as a "Gerrit Project" of X
    And X is configured to trigger upon Patchset Created on P
    And X is saved
    And AM is safely exited
    And a new Patchset PS is created on P
    Then a build of X should be triggered due to PS on HS

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when "Gerrit event" is changed on a job upon fail-over
    Given AM, HS, project P1, project P2, job X, Gerrit server S1, Gerrit server S2, Gerrit slave V1, Gerrit slave V2
    And P1 exists in S1
    And P2 exists in S2
    And V1 is a slave for S1
    And V2 is a slave for S2
    And S1 is configured as Server for "Gerrit event" of X
    And V1 is configured as Slave for "Gerrit event" of X
    And P1 is configured as a "Gerrit Project" of X
    And X is configured to trigger upon Patchset Created on P1
    When S2 is configured as Server for "Gerrit event" of X on AM
    And V2 is configured as Slave for "Gerrit event" of X
    And P2 is configured as a "Gerrit Project" of X
    And X is configured to trigger upon Comment Added on P2
    And X is saved
    And AM is safely exited
    And a new Patchset PS is created on P1 in S1
    And a new Comment CA is added on P2 in S2
    Then a build of X should be triggered due to CA on HS
    And no build of X should be triggered due to PS on HS

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when "Gerrit event" is removed as build trigger on a job upon fail-over
    Given AM, HS, project P, job X
    And a "Gerrit event" is configured as a build trigger on X
    And P is configured as a "Gerrit Project" of X
    And X is configured to trigger upon Patchset Created on P
    When the "Gerrit event" is removed as a build trigger from X on AM
    And X is saved
    And AM is safely exited
    And a new Patchset is created on P
    Then no build of X should be scheduled on HS

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when a 2nd "Gerrit Project" is added to a job upon fail-over
    Given AM, HS, project P1, project P2, job X
    And P1 is configured as a "Gerrit Project" of X
    And X is configured to trigger upon Patchset Created on P1
    When P2 is added as a "Gerrit Project" of X on AM
    And X is configured to trigger upon Patchset Created on P2
    And X is saved
    And AM is safely exited
    And a new Patchset PS1 is created on P1
    And a new Patchset PS2 is created on P2
    Then a build of X should be triggered due to PS1 on HS
    And a build of X should be triggered due to PS2 on HS

  @GerritTrigger
  Scenario: Gerrit Trigger is aware when a 2nd "Gerrit Project" is deleted from a job upon fail-over
    Given AM, HS, project P1, project P2, job X
    And P1 is configured as a "Gerrit Project" of X
    And P2 is configured as a "Gerrit Project" of X
    And X is configured to trigger upon Patchset Created on P1
    And X is configured to trigger upon Patchset Created on P2
    When P1 is deleted on AM
    And X is saved
    And AM is safely exited
    And a new Patchset PS1 is created on P1
    And a new Patchset PS1 is created on P2
    Then a build of X should be triggered due to PS2 on HS
    And no build of X should be triggered due to PS1 on HS

# Git plugin scenarios
  @GitPlugin
  Scenario: Git plugin is aware when a job's Git configuration is changed
    Given AM, HS, job X
    And X has Git SCM configurations
    When all fields and sub-fields of X's Git configuration are assigned with new valid values on AM
    And changes are saved
    Then these changes are replicated on HS accordingly

  @GitPlugin
  Scenario: Git plugin is aware when global configuration is changed
    Given AM, HS
    When all fields in Git Plugin global configuration are assigned new valid values on AM
    And changes are saved
    Then these changes are replicated on HS accordingly

  @GitPlugin
  Scenario: Git plugin is aware when a global Git installation is created
    Given AM, HS
    When a Git installation I is created on AM
    Then I is created on HS

  @GitPlugin
  Scenario: Git plugin is aware when a global Git installation is changed
    Given AM, HS, Git installation I
    When all fields and sub-fields for I are assigned new valid values on AM
    And changes are saved
    Then these changes are replicated on HS accordingly

  @GitPlugin
  Scenario: Git plugin is aware when a global Git installation is deleted
    Given AM, HS, Git installation I
    When I is deleted on AM
    Then I also is deleted on HS

  @GitPlugin
  Scenario: Git plugin is aware when job's Git SCM configuration is changed upon fail-over
    Given AM, HS, job X, repository URL R1, repository URL R2, branch B1, branch B2, credential C1, credential C2, executable E1, executable E2
    And X has Git SCM configurations
    And repository URL is configured to R1
    And credentials is configured to C1
    And branch is configured to B1
    And executable is configured to E1
    When R1 is changed R2 on AM
    And C1 is changed C2 on AM
    And B1 is changed B2 on AM
    And executable is changed to E2 on AM
    And X is saved
    And Active Master is safely exited
    And a build Z of X is triggered
    Then R2 should be cloned for Z using C2 & E2 on HS
    And B2 should be checked out

  @GitPlugin
  Scenario: Git plugin is aware when a job's Git SCM configuration is creating and selecting a new credential upon fail-over
    Given AM, HS, job X, repository URL R
    And X has Git SCM configurations
    And repository URL is configured to R
    When a new credential C is added on AM
    And C is selected
    And X is saved
    And Active Master is safely exited
    And a build Z of X is triggered
    Then R should be cloned for Z using C on HS

  @GitPlugin
  Scenario: Git plugin is aware when a configured credential is globally changed upon fail-over
    Given AM, HS, job X, repository URL R, credential C
    And X has Git SCM configurations
    And repository URL is configured to R
    And credentials is configured to C
    When C is globally updated with new values as C' on AM
    And Active Master is safely exited
    And a build Z of X is triggered
    Then R should be cloned for Z using C' on HS

  @GitPlugin
  Scenario: Git plugin is aware when a configured executable is globally changed upon fail-over
    Given AM, HS, job X, repository URL R, executable E
    And X has Git SCM configurations
    And repository URL is configured to R
    And executable is configured E
    When E is globally updated with new values as E' on AM
    And Active Master is safely exited
    And a build Z of X is triggered
    Then R should be cloned for Z using E' on HS

  @GitPlugin
  Scenario: Git plugin is aware when Git is added as SCM on a job upon fail-over
    Given AM, HS, repository URL R, job X
    When Git is added as an SCM of X on AM
    And repository URL is configured to R
    And X is saved
    And AM is safely exited
    And build B for X is triggered on HS
    Then B should clone R on HS

  @GitPlugin
  Scenario: Git plugin is aware when Git is removed as SCM on a job upon fail-over
    Given AM, HS, repository URL R, job X
    And Git is configured as an SCM of X on AM
    And repository URL is configured to R
    When Git is removed as an SCM from X on AM
    And X is saved
    And AM is safely exited
    And build B for X is triggered on HS
    Then B should not clone R on HS

# ldap plugin scenarios
  @LdapPlugin
  Scenario: LDAP plugin is aware when LDAP is enabled as security realm
    Given Jenkins Active Master, HS, user U1, U2 and LDAP properties set L
    And HAJP cluster is configured
    And LDAP plugin is installed
    And security is not enabled
    And user U1 is valid while U2 is not
    And L is valid LDAP configuration
    When security is enabled on Active Master
    And LDAP is selected as the security realm on Active Master
    And LDAP is configured with L
    And Active Master is safely exited
    Then User U1 should be able to log onto Jenkins HS
    And User U2 should not be able to log onto Jenkins HS

  @LdapPlugin
  Scenario: LDAP plugin is aware when LDAP configuration is changed
    Given Jenkins Active Master, HS, user U and LDAP properties set L1 and L2
    And HAJP cluster is configured
    And LDAP plugin is installed
    And LDAP is selected as the security realm on Active Master
    And L1 is valid LDAP configuration while L2 is not
    And user U is valid
    And LDAP is configured with L1
    When LDAP is re-configured with L2 on Active Master
    And Active Master is safely exited
    Then User U should not be able to log onto Jenkins HS

# Active Directory plugin scenarios
  @ActiveDirectoryPlugin
  Scenario: Active Directory plugin is aware when Active Directory is enabled as security realm
    Given Jenkins Active Master, HS, user U1, U2 and active directory properties set AD
    And HAJP cluster is configured
    And Active Directory plugin is installed
    And security is not enabled
    And user U1 is valid while U2 is not
    And AD is valid active directory configuration
    When security is enabled on Active Master
    And active directory is selected as the security realm on Active Master
    And active directory is configured with AD
    And Active Master is safely exited
    Then User U1 should be able to log onto Jenkins HS
    And User U2 should not be able to log onto Jenkins HS

  @ActiveDirectoryPlugin
  Scenario: Active Directory plugin is aware when its configuration is changed
    Given Jenkins Active Master, HS, user U and active directory properties set AD1 and AD2
    And HAJP cluster is configured
    And Active Directory plugin is installed
    And active directory is selected as the security realm on Active Master
    And AD1 is valid active directory configuration while AD2 is not
    And user U is valid
    And active directory is configured with AD1
    When active directory is re-configured with AD2 on Active Master
    And Active Master is safely exited
    Then User U should not be able to log onto Jenkins HS

# SSH Slaves plugin scenarios

# EnvInject plugin scenarios
  @EnvInjectPlugin
  Scenario: EnvInject plugin is aware when job level inherited environment variables are removed
    Given Jenkins Active Master, HS and job X
    And HAJP cluster is configured
    And EnvInject plugin is installed
    And "Prepare an environment for the run" is checked on configuration page of job X
    And "Keep Jenkins Environment Variables" is unchecked
    And "Keep Jenkins Build Variables" is unchecked
    When Active Master is safely exited
    And job X is built on Jenkins HS
    Then Text "Keeping Jenkins system variables" does not present on console output
    And Text "Keeping Jenkins build variables." does not present on console output

  @EnvInjectPlugin
  Scenario: EnvInject plugin is aware when job level scripts are added to run before SCM checkout
    Given Jenkins Active Master, HS, job X, valid script file F, valid script code S and valid property code P
    And HAJP cluster is configured
    And EnvInject plugin is installed
    And "Prepare an environment for the run" is checked on configuration page of job X
    And correct absolute path to F is filled in "Script File Path"
    And S is set as "Script Content"
    And P is set as "Properties Content"
    When Active Master is safely exited
    And job X is built on Jenkins HS
    Then I should see F, S and P are executed on the console output

  @EnvInjectPlugin
  Scenario: EnvInject plugin is aware when job level scripts are added to run as a build step
    Given Jenkins Active Master, HS, job X, valid property file F and valid property code P
    And HAJP cluster is configured
    And EnvInject plugin is installed
    And "Inject environment variables" is added as a build step of job X on Active Master
    And correct absolute path to F is filled in "Properties File Path"
    And P is set as "Properties Content"
    When Active Master is safely exited
    And job X is built on Jenkins HS
    Then I should see P is executed on the console output

  @EnvInjectPlugin
  Scenario: EnvInject plugin is aware when password is injected and masked as environment variables at job level
    Given Jenkins Active Master, HS, job password set P and job X
    And HAJP cluster is configured
    And EnvInject plugin is installed
    And "Inject passwords to the build as environment variables" is checked on configuration page of job X
    And "Mask password parameters" is checked
    And password set P is added as the only job password
    When Active Master is safely exited
    And job X is built on Jenkins HS
    Then Text "Mask passwords passed as build parameters." should present on console output
    And the job password of X matches values of P

# Throttle Concurrent Builds Plugin
  @ThrottleConcurrentBuildsPlugin
  Scenario: Throttle Concurrent Builds Plugin is aware when max builds per category is changed in global settings
    Given Jenkins Active Master, HS, multi-project throttle category C, job X and Y
    And HAJP cluster is configured
    And Throttle Concurrent Builds Plugin is installed
    And Throttle Concurrent Builds Plugin is not configured at job level
    And "Maximum Total Concurrent Builds" of C is set to zero in global settings
    And both job X and Y belongs to category C
    And both job X and Y takes fair amount of time to build
    And master node on both Jenkins Master and HS have more than one available executors for X and Y
    When "Maximum Total Concurrent Builds" of C is set to one on Active Master
    And Active Master is safely exited
    And job X and Y start to build almost at the same time with X started first on Jenkins HS
    Then job Y should be queued
    And job Y should start to build when X finishes

  @ThrottleConcurrentBuildsPlugin
  Scenario: Throttle Concurrent Builds Plugin is aware when max builds per node is changed in global settings
    Given Jenkins Active Master, HS, multi-project throttle category C, node N, job X and Y
    And HAJP cluster is configured
    And Throttle Concurrent Builds Plugin is installed
    And Throttle Concurrent Builds Plugin is not configured at job level
    And "Maximum Total Concurrent Builds" of C is set to zero in global settings
    And "Maximum Concurrent Builds Per Node" of C is set to zero in global settings
    And node N has more than one executors available for X and Y
    And both job X and Y belongs to category C
    And both job X and Y are configured to build on node N
    And both job X and Y takes fair amount of time to build
    When "Maximum Concurrent Builds Per Node" of C is set to one on Active Master
    And Active Master is safely exited
    And job X and Y start to build almost at the same time with X started first on Jenkins HS
    Then job Y should be queued
    And job Y starts to build when X finishes

  @ThrottleConcurrentBuildsPlugin
  Scenario: Throttle Concurrent Builds Plugin is aware when max value per labeled node is added in global settings
    Given Jenkins Active Master, HS, multi-project throttle category C, node N, node label L, job X and Y
    And HAJP cluster is configured
    And Throttle Concurrent Builds Plugin is installed
    And Throttle Concurrent Builds Plugin is not configured at job level
    And "Maximum Total Concurrent Builds" of C is set to zero in global settings
    And "Maximum Concurrent Builds Per Node" of C is set to zero in global settings
    And node N has label L
    And node N has more than one executors available for X and Y
    And both job X and Y belongs to category C
    And both job X and Y are configured to build on nodes with label L
    And both job X and Y takes fair amount of time to build
    When I click on "Add Maximum Per Labeled Node"
    And "Throttled Node Label" is set to L
    And "Maximum Concurrent Builds Per Node Labeled" is set to one
    And Active Master is safely exited
    And job X and Y start to build almost at the same time with X started first on Jenkins HS
    Then job Y should be queued
    And job Y starts to build when X finishes

  @ThrottleConcurrentBuildsPlugin
  Scenario: Throttle Concurrent Builds Plugin is aware when a single job's throttle configuration is changed
    Given Jenkins Active Master, HS and job X
    And HAJP cluster is configured
    And Throttle Concurrent Builds Plugin is installed
    And "Maximum Total Concurrent Builds" of job X is set to zero
    And job X takes fair amount of time to build
    And master node on both Jenkins Master and HS have more than one available executors for X
    When "Maximum Total Concurrent Builds" of job X is set to one
    And Active Master is safely exited
    And two builds of job X start to build almost at the same time on Jenkins HS
    Then only build NO.1 one starts
    And build NO.2 should start when build NO.1 is finished

  @ThrottleConcurrentBuildsPlugin
  Scenario: Throttle Concurrent Builds Plugin is aware when jobs are throttled as part of a category
    Given Jenkins Active Master, HS, multi-project throttle category C, job X and Y
    And HAJP cluster is configured
    And Throttle Concurrent Builds Plugin is installed
    And "Maximum Total Concurrent Builds" of C is set to one in global settings
    And "Maximum Concurrent Builds Per Node" of C is set to one in global settings
    And both job X and Y takes fair amount of time to build
    And master node on both Jenkins Master and HS have more than one available executors for X and Y
    When X and Y are both configured to be in category C
    And Active Master is safely exited
    And job X and Y start to build almost at the same time with X started first on Jenkins HS
    Then job Y should be queued
    And job Y starts to build when X finishes

  @ThrottleConcurrentBuildsPlugin
  Scenario: Throttle Concurrent Builds Plugin is aware when a job's throttle category is changed
    Given Jenkins Active Master, HS, multi-project throttle category C1 and C2, job X and Y
    And HAJP cluster is configured
    And Throttle Concurrent Builds Plugin is installed
    And "Maximum Total Concurrent Builds" of C1 is set to one in global settings
    And "Maximum Concurrent Builds Per Node" of C1 is set to one in global settings
    And "Maximum Total Concurrent Builds" of C2 is set to zero in global settings
    And "Maximum Concurrent Builds Per Node" of C2 is set to zero in global settings
    And both job X and Y takes fair amount of time to build
    And both job X and Y belongs to category C1
    And master node on both Jenkins Master and HS have more than one available executors for X and Y
    When X and Y are both re-configured to be in category C2
    And Active Master is safely exited
    And job X and Y start to build almost at the same time with X started first on Jenkins HS
    Then both job X and Y should start building
    And job Y should not wait for X to finish
