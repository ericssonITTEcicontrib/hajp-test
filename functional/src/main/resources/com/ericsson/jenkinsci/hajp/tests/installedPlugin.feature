Feature: Jenkins HAJP plugin installation verification

@PluginInstall
Scenario: HAJP Settings page should be available
  Given Jenkins is running on master 1
    And the hajp-core plugin is installed on master 1
  When I navigate to Manage Jenkins
  Then I can click on the HAJP Settings link

