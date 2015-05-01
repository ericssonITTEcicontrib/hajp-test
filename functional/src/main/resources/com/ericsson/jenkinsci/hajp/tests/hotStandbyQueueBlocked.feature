Feature: Hot Standby discards any queued item.

@HotStandbyQueueBlock
Scenario: Hot Standby will not let a queued item leave the queue and must remove the item.
  Given Jenkins is running on master 1
    And Jenkins is running on master 2
    And the hajp-core plugin is installed on master 1
    And the hajp-core plugin is installed on master 2
    And master 1 is joined to the cluster
    And master 2 is joined to the cluster
    And the cluster is formed
    And master 2 has the hot standby role
  When an item is added to the queue on master 2
  Then the item will be discarded on master 2
