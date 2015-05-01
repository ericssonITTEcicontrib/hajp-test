package com.ericsson.jenkinsci.hajp;

import lombok.extern.log4j.Log4j2;
import org.junit.runner.Description;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunListener;

/**
 * Test Execution Listener that will output progress of tests
 */
@Log4j2 public class ExecutionListener extends RunListener {
    /**
     * Called before any tests have been run.
     */
    public void testRunStarted(Description description) throws java.lang.Exception {
        log.info("Number of testcases to execute : " + description.testCount());
    }

    /**
     * Called when all tests have finished
     */
    public void testRunFinished(Result result) throws java.lang.Exception {
        log.info("Number of testcases executed : " + result.getRunCount());
    }

    /**
     * Called when an atomic test is about to be started.
     */
    public void testStarted(Description description) throws java.lang.Exception {
        log.info("Starting execution of test case : " + description.getMethodName());
    }

    /**
     * Called when an atomic test has finished, whether the test succeeds or fails.
     */
    public void testFinished(Description description) throws java.lang.Exception {
        log.info("Finished execution of test case : " + description.getMethodName());
    }

    /**
     * Called when an atomic test fails.
     */
    public void testFailure(Failure failure) throws java.lang.Exception {
        log.info("Execution of test case failed : " + failure.getMessage());
    }

    /**
     * Called when a test will not be run, generally because a test method is annotated with Ignore.
     */
    public void testIgnored(Description description) throws java.lang.Exception {
        log.info("Execution of test case ignored : " + description.getMethodName());
    }
}
