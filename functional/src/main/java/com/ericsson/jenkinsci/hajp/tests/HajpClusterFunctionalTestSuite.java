package com.ericsson.jenkinsci.hajp.tests;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import org.junit.runner.RunWith;

/**
 * cluster functional tests for hajp plugin: join, leave, and failover
 */
@RunWith(Cucumber.class) @CucumberOptions(monochrome = true,
    tags = {"@ClusterHAFunctional"},
    format = {"pretty", "html:target/cucumber", "rerun:target/rerun.txt"})
public class HajpClusterFunctionalTestSuite {
}
