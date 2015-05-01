package com.ericsson.jenkinsci.hajp;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import lombok.extern.log4j.Log4j2;
import org.apache.commons.logging.LogFactory;
import org.junit.Assert;
import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.NoAlertPresentException;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.List;
import java.util.logging.Level;

/**
 * A util class that contains some useful methods
 */
@Log4j2 public class SeleniumUtil {

    public static final String ERROR_MESSAGE_ALERT = "Jenkins alert error.";
    public static final String ERROR_MESSAGE_ELEMENT_NOT_FOUND = "Element cannot be found. ";
    public static final String BOTTOM_SCROLLBAR = "//div[@class=\"ft bottomscrollbar\"]";
    public static final String TEXT_DELETE_PROJECT = "Delete Project";
    public static final String ID_NAME = "name";
    public static final String ID_OK_BUTTON = "ok-button";
    public static final String NAME_MODE = "mode";
    public static final String TEXT_NEW_JOB = "New Job";
    public static final String TEXT_NEW_ITEM = "New Item";
    public static final String ERROR_MESSAGE_JENKINS = "Element not found. Jenkins issue.";
    public static final String BUTTON_SAVE = "Save";
    public static final String SUBMIT_BUTTON = "Submit";


    /**
     * url surfix of hajp config
     */
    public final static String HAJP_CONFIG_URL = "/HAJPconfig";
    /**
     * url surfix of safely resarting jenkins
     */
    public final static String SAFE_RESTART_URL = "/safeRestart";

    /**
     * status keyword of jenkins instance in the cluster: disconnected
     */
    public final static String DISCONNECTED = "DISCONNECTED";
    /**
     * status keyword of jenkins instance in the cluster: joined
     */
    public final static String JOINED = "JOINED";

    /**
     * the id of tag used in jenkins frontend showing master role
     */
    public static final String ID_MASTER_ROLE = "master.role";
    /**
     * the id of tag used in jenkins frontend showing cluster status
     */
    public final static String ID_CLUSTER_STATUS = "cluster_status";

    /**
     * the role of jenkins instance: active master
     */
    public final static String ACTIVE_MASTER = "Active Master";
    /**
     * the role of jenkins instance: active master
     */
    public final static String HOT_STANDBY = "Hot Standby";


    /**
     * Checks if an element presents on the web page
     *
     * @param driver current {@link WebDriver}
     * @param by     {@link By} object used for locating the element
     * @return true if the element can be found, false otherwise
     */
    public static boolean isElementPresent(final WebDriver driver, By by) {
        try {
            driver.findElement(by);
            return true;
        } catch (NoSuchElementException e) {
            return false;
        }
    }

    /**
     * Accept a web alert pop up whose text matches the given text
     *
     * @param driver      current {@link WebDriver}
     * @param matchedText text String to be matched against
     * @return true if the alert is accepted, false otherwise
     */
    public static boolean acceptAlert(final WebDriver driver, String matchedText) {
        boolean isAccepted = false;
        try {
            Alert alert = driver.switchTo().alert();
            String alertText = alert.getText();
            if (alertText != null && matchedText != null) {
                if (alertText.matches(matchedText)) {
                    isAccepted = true;
                }
            }
            if (isAccepted) {
                alert.accept();
            } else {
                alert.dismiss();
            }
        } catch (NoAlertPresentException e) {
            System.err.println(ERROR_MESSAGE_ALERT);
        }
        return isAccepted;
    }

    /**
     * Find an element by its type and exact display text
     *
     * @param driver      current {@link WebDriver}
     * @param elementName the display text of the element to be found
     * @param elementType the type of the element to be found
     * @return the element if found
     * @throws NoSuchElementException if the element cannot be found
     */
    public static WebElement findElement(WebDriver driver, String elementName, By elementType)
        throws NoSuchElementException {
        List<WebElement> allElements;
        allElements = driver.findElements(elementType);
        return searchForElementUntilItCannotBeFound(driver, allElements, elementName, elementType);
    }

    private static WebElement searchForElementUntilItCannotBeFound(WebDriver driver,
        List<WebElement> allElements, String elementName, By elementType) {
        boolean noSuchElementFound = false;
        do {
            for (WebElement singleElement : allElements) {
                if (singleElement.getText().equals(elementName)) {
                    return singleElement;
                }
            }
            try {
                driver.findElement(By.xpath(BOTTOM_SCROLLBAR)).click();
                allElements = driver.findElements(elementType);
            } catch (NoSuchElementException e) {
                System.err.println(ERROR_MESSAGE_ELEMENT_NOT_FOUND + e.getMessage());
                noSuchElementFound = true;
            }
        } while (!noSuchElementFound);
        throw new NoSuchElementException(ERROR_MESSAGE_ELEMENT_NOT_FOUND);
    }

    /**
     * Fill in a input box with given value
     *
     * @param driver current {@link WebDriver}
     * @param by     the {@link By} used for locating the element
     * @param value  the value to be set
     */
    public static void setFieldToValue(WebDriver driver, By by, String value) {
        driver.findElement(by).clear();
        driver.findElement(by).sendKeys(value);
    }

    /**
     * Go to configuration page of a job
     *
     * @param driver  current {@link WebDriver}
     * @param jobName job name
     */
    public static void configureJob(WebDriver driver, String url, String jobName) {
        driver.get(url);
        driver.findElement(By.linkText(jobName)).click();
        driver.findElement(By.cssSelector("a[href*='/job/" + jobName + "/configure']")).click();
    }

    /**
     * Return console output of the latest build of a Jenkins job<br>
     * If the latest build is not finished at the time this method is invoked, the method will wait for it to finish
     *
     * @param driver  current {@link WebDriver}
     * @param jobName job name
     * @return console output of the build
     * @throws InterruptedException if any
     */
    public static String getLatestBuildOutput(WebDriver driver, String url, String jobName)
        throws InterruptedException {
        goToLatestBuild(driver, url, jobName);
        driver.findElement(By.linkText("Console Output")).click();
        WebElement console = driver.findElement(By.cssSelector(".console-output"));
        return getFinalConsoleOutput(console);
    }

    /**
     * Build the give Jenkins job
     *
     * @param driver  current {@link WebDriver}
     * @param jobName name of the job to be built
     */
    public static void buildJobNow(WebDriver driver, String url, String jobName) {
        driver.get(url);
        driver.findElement(By.linkText(jobName)).click();
        driver.findElement(By.cssSelector("a[href*='/job/" + jobName + "/build?delay=0sec']"))
            .click();
    }

    /**
     * Checks if the latest build of a job succeeded
     *
     * @param driver  current {@link WebDriver}
     * @param jobName job name
     * @return true if latest build was successful, false otherwise
     * @throws InterruptedException if any
     */
    public static boolean isLatestBuildSuccessful(WebDriver driver, String url, String jobName)
        throws InterruptedException {
        final String RESULT_SUCCESS = "Finished: SUCCESS";
        return getLatestBuildOutput(driver, url, jobName).contains(RESULT_SUCCESS);
    }

    /**
     * Go to the latest build page of a Jenkins job
     *
     * @param driver  current {@link WebDriver}
     * @param jobName job name
     * @return URL of the latest build (e.g. http://localhost:8080/job/job_name/1/)
     */
    public static String goToLatestBuild(WebDriver driver, String url, String jobName) {
        String latestBuildLinkXpath = ".//*[@id='buildHistory']/div[2]/table/tbody/tr[1]/td[2]/a";
        driver.get(url);
        driver.findElement(By.linkText(jobName)).click();
        driver.findElement(By.xpath(latestBuildLinkXpath)).click();
        return driver.getCurrentUrl();
    }

    /**
     * Delete a Jenkins job identified by its name and confirm it is no longer present on main page
     *
     * @param driver  current {@link WebDriver}
     * @param jobName job name
     * @throws InterruptedException if any
     */
    public static void deleteJobAndConfirmDeletion(WebDriver driver, String url, String jobName)
        throws InterruptedException {
        String jobURL = url + "/job/" + jobName;
        assertTrue(deleteJob(driver, jobURL, jobName));
        assertFalse(SeleniumUtil.isElementPresent(driver, By.linkText(jobName)));
    }

    /**
     * Delete a job identified by its name
     *
     * @param driver  current {@link WebDriver}
     * @param baseUrl URL to the job page e.g. http://localhost:8080/job/The_Job/
     * @param jobName name of the job to be deleted
     * @return true if action succeeds, false otherwise
     * @throws InterruptedException if any
     */
    public static boolean deleteJob(WebDriver driver, String baseUrl, String jobName)
        throws InterruptedException {
        driver.get(baseUrl);
        try {
            driver.findElement(By.linkText(TEXT_DELETE_PROJECT)).click();
        } catch (NoSuchElementException e) {
            System.err.println(ERROR_MESSAGE_JENKINS + e.getMessage());
            return false;
        }
        String alertTextToMatch =
            "^Are you sure about deleting the Project â€˜" + jobName + "â€™[\\s\\S]$";
        assertTrue(SeleniumUtil.acceptAlert(driver, alertTextToMatch));
        Thread.sleep(3000);
        return true;
    }


    private static String getFinalConsoleOutput(WebElement console) throws InterruptedException {
        final String FINISHED = "Finished: ";
        while (!console.getText().contains(FINISHED)) {
            Thread.sleep(10000);
        }
        return console.getText();
    }

    /**
     * Create a new job with given name
     *
     * @param driver  current {@link WebDriver}
     * @param baseUrl URL to home page of the given Jenkins instance e.g. localhost:8080
     * @param jobName name of the job to be created
     * @return true if action succeeds, false otherwise
     * @throws InterruptedException if any
     */
    public static boolean createJob(final WebDriver driver, String baseUrl, String jobName)
        throws InterruptedException {
        driver.get(baseUrl);
        try {
            driver.findElement(By.linkText(SeleniumUtil.TEXT_NEW_ITEM)).click();
        } catch (NoSuchElementException e1) {
            System.err.println(SeleniumUtil.ERROR_MESSAGE_JENKINS + e1.getMessage());
            return false;
        }
        try {
            SeleniumUtil.setFieldToValue(driver, By.id(SeleniumUtil.ID_NAME), jobName);
            driver.findElement(By.name(SeleniumUtil.NAME_MODE)).click();
            driver.findElement(By.id(SeleniumUtil.ID_OK_BUTTON)).click();
            driver.findElement(By.name(SeleniumUtil.SUBMIT_BUTTON)).submit();
        } catch (NoSuchElementException e) {
            System.err.println(SeleniumUtil.ERROR_MESSAGE_JENKINS + e.getMessage());
            return false;
        }
        return true;
    }

    /**
     * turn off logs for HtmlUnitDriver
     */
    public static void silenceHtmlUnitDriver() {
        LogFactory.getFactory().setAttribute("org.apache.commons.logging.Log",
            "org.apache.commons.logging.impl.NoOpLog");
        java.util.logging.Logger.getLogger("com.gargoylesoftware.htmlunit").setLevel(Level.OFF);
        java.util.logging.Logger.getLogger("org.apache.commons.httpclient").setLevel(Level.OFF);
        java.util.logging.Logger
            .getLogger("com.gargoylesoftware.htmlunit.javascript.StrictErrorReporter")
            .setLevel(Level.OFF);
        java.util.logging.Logger
            .getLogger("com.gargoylesoftware.htmlunit.javascript.host.ActiveXObject")
            .setLevel(Level.OFF);
        java.util.logging.Logger
            .getLogger("com.gargoylesoftware.htmlunit.javascript.host.html.HTMLDocument")
            .setLevel(Level.OFF);
        java.util.logging.Logger.getLogger("com.gargoylesoftware.htmlunit.html.HtmlScript")
            .setLevel(Level.OFF);
        java.util.logging.Logger
            .getLogger("com.gargoylesoftware.htmlunit.javascript.host.WindowProxy")
            .setLevel(Level.OFF);
        java.util.logging.Logger.getLogger("org.apache").setLevel(Level.OFF);
    }

    /**
     * get the web element satisfying {@link By}
     *
     * @param browser the web browser to be used
     * @param url     the url to obtain the resource
     * @return the satisfying web element
     */
    public static WebElement getWebElement(WebDriver browser, String url, By by) {
        browser.get(url);
        return browser.findElement(by);
    }

    private static String getUrlForMaster(int arg1) {
        return HajpEnvironmentSetup.getUrlForMaster(arg1);
    }

    private static String getMasterAddress(int arg1) {
        return HajpEnvironmentSetup.getMasterAddress(arg1);
    }

    private static String getPortOfMaster(int arg1) {
        return HajpEnvironmentSetup.getPortOfMaster(arg1);
    }

    /**
     * check whether, or not, jenkins instance {@code index} is in the cluster
     *
     * @param browser the browser to use
     * @param index   the index of jenkins instance
     * @param status  the status to check
     */
    public static void inCluster(WebDriver browser, int index, String status) {
        WebElement obj = SeleniumUtil
            .getWebElement(browser, getUrlForMaster(index) + HAJP_CONFIG_URL,
                By.id(ID_CLUSTER_STATUS));
        String result = obj.getText();
        Assert.assertEquals("Should be " + status, status, result);
    }

    /**
     * make jenkins instance {@code index} join the cluster
     *
     * @param browser the browser to use
     * @param index   the index of jenkins instance
     */
    public static void joinCluster(WebDriver browser, int index) {
        browser.get(getUrlForMaster(index) + HAJP_CONFIG_URL);
        browser.findElement(By.name("ip")).clear();
        browser.findElement(By.name("ip")).sendKeys(getMasterAddress(index));
        browser.findElement(By.name("port")).clear();
        browser.findElement(By.name("port")).sendKeys(getPortOfMaster(index));
        browser.findElement(By.xpath("(//input[@name='ip'])[2]")).clear();
        browser.findElement(By.xpath("(//input[@name='ip'])[2]"))
            .sendKeys(HajpEnvironmentSetup.orchestratorAddress);
        browser.findElement(By.xpath("(//input[@name='port'])[2]")).clear();
        browser.findElement(By.xpath("(//input[@name='port'])[2]"))
            .sendKeys(HajpEnvironmentSetup.orchestratorPort);
        browser.findElement(By.name("submitClusterMembers")).submit();
    }

    /**
     * restart jenkis instance {@code index}
     *
     * @param browser the browser to use
     * @param index   the index of jenkins instance
     */
    public static void restart(WebDriver browser, int index) {
        browser.get(getUrlForMaster(index) + SAFE_RESTART_URL);
        browser.findElement(By.name(SUBMIT_BUTTON)).submit();
    }

    /**
     * to check if jenkins instance {@code index} has the role {@code role}
     *
     * @param browser the browser to use
     * @param index   the index of jenkins instance
     * @param role    the role to check
     * @throws Throwable
     */
    public static void hasRole(WebDriver browser, int index, String role) {
        WebElement obj = SeleniumUtil
            .getWebElement(browser, getUrlForMaster(index) + HAJP_CONFIG_URL,
                By.id(ID_MASTER_ROLE));

        //browser.get(getUrlForMaster(index) + HAJP_CONFIG_URL);
        //WebElement obj = browser.findElement(By.id("master.role"));
        String result = obj.getText();
        log.debug("=" + result + "=");
        Assert.assertEquals("Should be " + role, role, result);
    }
}
