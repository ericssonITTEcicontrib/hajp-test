# General description:
# Since there are currently no cluster operations to enable plugin/core synchronization
# these proposed scenarios require manual operations to be applied on the Hot Standby instances.
#
# Assumptions:
# - Plugin P can be considered as a group of 1-n plugins
# - A = Active master, HS = 1 or more Hot standby instances
# - Hot standby instance reconnects to the cluster upon start-up
# - When a Hot standby connects the cluster all jobs & builds from A are replicated to it

Feature: Core upgrade and plugin updates (install, upgrade, disable, uninstall)
  Any change to core or plugin must be replicated across the cluster members.

  Scenario: Immediate installation of a new plugin on the active instance that does not require a restart
    Given: A is running
    And: HS are shutdown
    And: a new plugin P is available for installation in the Plugin Manager UI
    And: P is selected for installation
    And: the installation does not require a restart of the instance
    And: “Install without restart” is clicked
    When: Installation of P on A is completed
    And: P with its dependencies will be manually copied to HS’s plugins folder on the file-system
    And: HS will be manually started
    Then: P with its dependencies will be available for use on A & HS

  Scenario: Deferred installation of a new plugin on the active instance that does not require a restart
    Given: A & HS are running
    And: a new plugin P is available for installation in the Plugin Manager UI
    And: P is selected for installation
    And: the installation does not require a restart of the instance
    And: “Download now and install after restart” is clicked
    When: Installation of P on A is completed
    And: P will be manually installed on the HS instances in a similar fashion as done on A
    And: P with its dependencies will be available on A & HS’s file-systems
    And: HS will be manually shut down
    And: A will be manually restarted
    And: HS will be manually started
    Then: P with its dependencies will be available for use on A & HS

  Scenario: Installation of a new plugin on the active instance that does require a restart
    Given: A & HS are running
    And: a new plugin P is available for installation in the Plugin Manager UI
    And: P is selected for installation
    And: the installation does require a restart of the instance
    And: “Install without restart” or “Download now and install after restart” is clicked
    When: Installation of P on A is completed
    And: P will be manually installed on the HS instances in a similar fashion as done on A
    And: P with its dependencies will be available on A & HS’s file-systems
    And: HS will be manually shut down
    And: A will manually be restarted
    And: HS will be manually started
    Then: P with its dependencies will be available for use on A & HS

  Scenario: Upgrading a plugin on the active instance (require a restart)
    Given: A & HS are running
    And: a new plugin version P is available for upgrade in the Plugin Manager UI
    And: P is selected for installation
    And: “Install without restart” or “Download now and install after restart” is clicked
    When: Installation of P on A is completed
    And: P will be manually installed on the HS instances in a similar fashion as done on A
    And: P with its dependencies will be available on A & HS’s file-systems
    And: HS will be manually shut down
    And: A will manually be restarted
    And: HS will be manually started
    Then: P with its dependencies will be available for use on A & HS

  Scenario: Disabling or Uninstalling a plugin on the active instance (require a restart)
    Given: A & HS are running
    And: a plugin P exists in the Installed tab on the Plugin Manager UI
    And: P is designated to be disabled/uninstalled
    And: “Restart Once No Jobs Are Running” is clicked
    When: Update of P on A is completed
    And: P will be manually updated on the HS instances in a similar fashion as done on A
    And: P will be updated on A & HS’s file-systems
    And: HS will be manually shut down
    And: A will manually be restarted
    And: HS will be manually started
    Then: P will be disabled/uninstalled on A & HS

  Scenario: Upgrading the core on the active instance (require a restart)
    Given: A & HS are running
    And: a new core version C is available for upgrade
    When: core update  is completed on A
    And: C will be manually upgraded on the HS instances in a similar fashion as done on A
    And: A & HS’s file-systems will be ready for the core-upgrade
    And: HS will be manually shut down
    And: A will manually be restarted
    And: HS will be manually started
    Then: A & HS will be upgraded to C

# Excluded Scenarios:
# - File-System changes to plugins - In case a plugin is “hacked” into the instance by placing it in the
#   plugins folder under jenkins_home HAJP does not monitor for this and the plugin will not be replicated.
#   These “hacks” should be done on both instances.
# - Downgrading plugins - need to investigate and add these scenarios!

# --- Potential implementation for future development ---
# General description:
# If a new plugin can be installed without restart it will be installed on all instances on-the-fly.
# Otherwise, the update is deferred (ready on the File-System) and a restart of the whole cluster is required.
# The 1st cluster member to “recover” will become the Active Master.
#
# Assumptions:
# - Plugin P can be considered as a group of 1-n plugins
# - A = Active master, HS = 1 or more Hot standby instances
# - All Messages are sent from A to all HS instance
# - Messages are handled by HS by the order they are sent from A

  @todo
  Scenario: Immediate installation of a new plugin on the active instance that does not require a restart
    Given: A & HS are synched
    And: a new plugin P is available for installation in the Plugin Manager UI
    And: P is selected for installation
    And: the installation does not require a restart of the instance
    And: “Install without restart” is clicked
    When: Installation of P on A is completed
    Then: install-no-restart(P) message will be sent
    And: Installation of P on HS will be completed
    And: P with its dependencies will be available for use on A & HS

  @todo
  Scenario: Deferred  installation of a new plugin on the active instance that does not require a restart
    Given: A & HS are synched
    And: a new plugin P is available for installation in the Plugin Manager UI
    And: P is selected for installation
    And: the installation does not require a restart of the instance
    And: “Download now and install after restart” is clicked
    When: Installation of P on A is completed
    Then: install-with-restart(P) message will be sent
    And: Installation of P on HS will be completed
    And: P with its dependencies will be downloaded on A & HS
    And: A & HS are marked as updated

  @todo
  Scenario: Installation of a new plugin on the active instance that does require a restart
    Given: A & HS are synched
    And: a new plugin P is available for installation in the Plugin Manager UI
    And: P is selected for installation
    And: the installation does require a restart of the instance
    And: “Install without restart” or “Download now and install after restart” is clicked
    When: Installation of P on A is completed
    Then: install-with-restart(P) message will be sent
    And: Installation of P on HS will be completed
    And: P with its dependencies will be downloaded on A & HS
    And: A & HS are marked as updated

  @todo
  Scenario: Upgrading a plugin on the active instance (require a restart)
    Given: A & HS are synched
    And: a new plugin version P is available for upgrade in the Plugin Manager UI
    And: P is selected for installation
    And: “Install without restart” or “Download now and install after restart” is clicked
    When: Installation of P on A is completed
    Then: install-with-restart(P) message will be sent
    And: Installation of P on HS will be completed
    And: P with its dependencies will be downloaded on A & HS
    And: A & HS are marked as updated

  @todo
  Scenario: Disabling or Uninstalling a plugin on the active instance (require a restart)
    Given: A & HS are synched
    And: a plugin P exists in the Installed tab on the Plugin Manager UI
    And: P is designated to be disabled/uninstalled
    And: “Restart Once No Jobs Are Running” is clicked
    When: Update of P on A is completed
    And: disable/uninstall(P) message will be sent
    And: P will be designated to be disabled/uninstalled on A & HS
    And: A & HS are marked as updated

  @todo
  Scenario: Upgrading the core on the active instance (require a restart)
    Given: A & HS are synched
    And: a new core version C is available for upgrade
    When: HAJP is triggered that core upgrade  on A was completed
    Then: upgrade-core(C) message will be sent
    And: A & HS’s file-systems will be ready for the core-upgrade
    And: A & HS are marked as updated

  @todo
  Scenario: Restart marked instances
    Given: A & HS are marked as updated
    When: A is being restarted
    Then: restart message will be sent
    And: A & HS will be restarted

# Missing scenarios:
# - What happens in case an HS instance fails to update?
# - What happens if there is a crash during the update process on A or HS?

