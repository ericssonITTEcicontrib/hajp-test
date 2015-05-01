package com.ericsson.jenkinsci.hajp.tests;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import org.junit.runner.RunWith;

/**
 * TODO
 * Currently this class contains the tests for @PluginInstall and @HotStandbyQueueBlock
 * Update the name of this class according to tests included in the future
 */
@RunWith(Cucumber.class) @CucumberOptions(monochrome = true,
    tags = {"@PluginInstall,@HotStandbyQueueBlock"},
    format = {"pretty", "html:target/cucumber", "rerun:target/rerun.txt"})
public class HajpFunctionalTestSuite {
}
