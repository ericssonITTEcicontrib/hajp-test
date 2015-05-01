package com.ericsson.jenkinsci.hajp.tests;

import static org.junit.Assert.assertEquals;

import com.ericsson.jenkinsci.hajp.EnvironmentUtil;
import com.ericsson.jenkinsci.hajp.HajpEnvironmentSetup;
import com.ericsson.jenkinsci.hajp.SeleniumUtil;
import cucumber.api.java.After;
import cucumber.api.java.Before;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.htmlunit.HtmlUnitDriver;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Random;
import java.util.concurrent.TimeUnit;
import javax.xml.parsers.DocumentBuilderFactory;

/**
 * Step definitions for Plugin Installation Verification
 */
@Log4j2 public class HajpTestStepDefinitions {

    private final static long JOIN_SLEEPING_TIME = 5 * 1000;
    private WebDriver browser;

    private static String getUrlForMaster(int arg1) {
        return HajpEnvironmentSetup.getUrlForMaster(arg1);
    }

    @Before("@PluginInstall,@HotStandbyQueueBlock") public void setup() throws IOException {
        log.info("======HajpTestStepDefinitions: setup ==========");
        EnvironmentUtil.cleanUp();

        browser = new HtmlUnitDriver(true);
        SeleniumUtil.silenceHtmlUnitDriver();
        browser.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

    @After("@PluginInstall,@HotStandbyQueueBlock") public void afterScenario() {
        browser.close();
    }

    @Given("^Jenkins is running on master (\\d+)$")
    public void Jenkins_is_running_on_master(int arg1) throws Throwable {
        browser.get(getUrlForMaster(arg1));
    }

    @Given("^the hajp-core plugin is installed on master (\\d+)$")
    public void the_hajp_core_plugin_is_installed(int arg1) throws Throwable {
        browser.get(getUrlForMaster(arg1) + "/HAJPconfig");
    }

    @When("^I navigate to Manage Jenkins$") public void I_navigate_to_Manage_Jenkins()
        throws Throwable {
        browser.get(getUrlForMaster(1) + "/manage");
    }

    @Then("^I can click on the HAJP Settings link$")
    public void I_can_click_on_the_HAJP_Settings_link() throws Throwable {
        browser.get(getUrlForMaster(1) + "/HAJPconfig");
    }

    @Given("^master (\\d+) is joined to the cluster$")
    public void master_is_joined_to_the_cluster(int arg1) throws Throwable {
        SeleniumUtil.joinCluster(browser, arg1);
        log.info(
            "testing sleeps for some seconds since master " + arg1 + " is joining the cluster");
        Thread.sleep(JOIN_SLEEPING_TIME);
        SeleniumUtil.inCluster(browser, arg1, SeleniumUtil.JOINED);
    }

    @Given("^the cluster is formed$") public void the_cluster_is_formed() throws Throwable {
    }

    @Given("^master (\\d+) has the hot standby role$")
    public void master_has_the_hot_standby_role(int arg1) throws Throwable {
        SeleniumUtil.hasRole(browser, arg1, SeleniumUtil.HOT_STANDBY);
    }

    @When("^an item is added to the queue on master (\\d+)$")
    public void an_item_is_added_to_the_queue_on_master(int arg1) throws Throwable {
        String jobName = new Double(new Random().nextDouble()).toString();
        SeleniumUtil.createJob(browser, getUrlForMaster(arg1), jobName);
        SeleniumUtil.buildJobNow(browser, getUrlForMaster(arg1), jobName);
    }

    @Then("^the item will be discarded on master (\\d+)$")
    public void the_item_will_be_discarded_on_master(int arg1) throws Throwable {

        Thread.sleep(5000);
        browser.get(getUrlForMaster(arg1) + "/queue/api/xml");
        String queueXml = browser.getPageSource();

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        Document doc = factory.newDocumentBuilder()
            .parse(new ByteArrayInputStream(queueXml.getBytes(StandardCharsets.UTF_8)));
        NodeList nodes = doc.getElementsByTagName("item");
        assertEquals(0, nodes.getLength());
    }
}
