package com.ericsson.jenkinsci.hajp.tests;

import com.ericsson.jenkinsci.hajp.EnvironmentUtil;
import com.ericsson.jenkinsci.hajp.HajpEnvironmentSetup;
import com.ericsson.jenkinsci.hajp.SeleniumUtil;
import com.ericsson.jenkinsci.hajp.ShellUtil;
import cucumber.api.java.After;
import cucumber.api.java.Before;
import cucumber.api.java.en.And;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import lombok.extern.log4j.Log4j2;
import org.junit.Assert;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.htmlunit.HtmlUnitDriver;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * Step definitions for cluster functional tests
 */
@Log4j2 public class HajpClusterTestStepDefinitions {

    private final static long RESTART_SLEEPING_TIME = 30 * 1000;
    private final static long JOIN_SLEEPING_TIME = 5 * 1000;
    private WebDriver browser;

    @Before("@ClusterHAFunctional") public void setup() throws IOException {
        log.info("======HajpClusterTestStepDefinitions: setup ==========");
        EnvironmentUtil.cleanUp();

        browser = new HtmlUnitDriver(true);
        SeleniumUtil.silenceHtmlUnitDriver();
        browser.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

    @After("@ClusterHAFunctional") public void afterScenario() {
        browser.close();
    }


    @And("^there is an orchestrator$") public void there_is_an_orchestrator() throws Throwable {
        // Daniel: checking by pinging orchestrator's ip
        // TODO hk: more standard checking service should be implemented
        String command = "ping -i 1 -c 3 " + HajpEnvironmentSetup.orchestratorAddress;
        ShellUtil.ShellResult result = ShellUtil.run(command);
        Assert.assertEquals(0, result.exitValue);
    }


    @Given("^jenkins instance (\\d+) has not yet joined the cluster$")
    public void jenkins_instance_has_not_yet_joined_the_cluster(int arg1) throws Throwable {
        SeleniumUtil.inCluster(browser, arg1, SeleniumUtil.DISCONNECTED);
    }

    @When("^click join on jenkins instance (\\d+)$")
    public void click_join_on_jenkins_instance(int arg1) throws Throwable {
        SeleniumUtil.joinCluster(browser, arg1);
        log.info(
            "testing sleeps for some seconds since master " + arg1 + " is joining the cluster");
        Thread.sleep(JOIN_SLEEPING_TIME);
    }

    @Then("^jenkins instance (\\d+) joins the cluster$")
    public void jenkins_instance_joins_the_cluster(int arg1) throws Throwable {
        SeleniumUtil.inCluster(browser, arg1, SeleniumUtil.JOINED);
    }

    @Given("^jenkins instance (\\d+) has joined the cluster$")
    public void jenkins_instance_has_joined_the_cluster(int arg1) throws Throwable {
        SeleniumUtil.joinCluster(browser, arg1);
        log.info(
            "testing sleeps for some seconds since master " + arg1 + " is joining the cluster");
        Thread.sleep(JOIN_SLEEPING_TIME);
        SeleniumUtil.inCluster(browser, arg1, SeleniumUtil.JOINED);
    }

    @When("^jenkins instance (\\d+) is restarted$")
    public void jenkins_instance_is_restarted(int arg1) throws Throwable {
        SeleniumUtil.restart(browser, arg1);
        log.info("testing sleeps for some seconds since master " + arg1 + " is just restarted");
        // TODO fix a standard for failover success
        // Scott: make a loop with a limited upperbound
        // get Daniel's opinion and then implement: Await
        Thread.sleep(RESTART_SLEEPING_TIME);
    }

    @Then("^jenkins instance (\\d+) is not the cluster$")
    public void jenkins_instance_is_not_the_cluster(int arg1) throws Throwable {
        SeleniumUtil.inCluster(browser, arg1, SeleniumUtil.DISCONNECTED);
    }

    @Given("^jenkins instance (\\d+) has the active master role$")
    public void jenkins_instance_has_the_active_master_role(int arg1) throws Throwable {
        SeleniumUtil.joinCluster(browser, arg1);
        log.info(
            "testing sleeps for some seconds since master " + arg1 + " is joining the cluster");
        Thread.sleep(JOIN_SLEEPING_TIME);
        SeleniumUtil.inCluster(browser, arg1, SeleniumUtil.JOINED);
        SeleniumUtil.hasRole(browser, arg1, SeleniumUtil.ACTIVE_MASTER);
    }

    @And("^jenkins instance (\\d+) has the hot standby master role$")
    public void jenkins_instance_has_the_hot_standby_master_role(int arg1) throws Throwable {
        SeleniumUtil.joinCluster(browser, arg1);
        log.info(
            "testing sleeps for some seconds since master " + arg1 + " is joining the cluster");
        Thread.sleep(JOIN_SLEEPING_TIME);
        SeleniumUtil.inCluster(browser, arg1, SeleniumUtil.JOINED);
        SeleniumUtil.hasRole(browser, arg1, SeleniumUtil.HOT_STANDBY);
    }

    @Then("^jenkins instance (\\d+) becomes the active master role$")
    public void jenkins_instance_becomes_the_active_master_role(int arg1) throws Throwable {
        SeleniumUtil.hasRole(browser, arg1, SeleniumUtil.ACTIVE_MASTER);
    }

}
