package com.ericsson.jenkinsci.hajp;

import com.ericsson.jenkinsci.hajp.tests.HajpClusterFunctionalTestSuite;
import com.ericsson.jenkinsci.hajp.tests.HajpFunctionalTestSuite;
import lombok.extern.log4j.Log4j2;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.junit.runner.Computer;
import org.junit.runner.JUnitCore;
import org.junit.runner.Result;

import java.util.ArrayList;
import java.util.List;

/**
 * This application is responsible for launching the feature tests.<br>
 * <br>
 * Mandatory argument(s) is(are):<br>
 * <br>
 * --deploy deployFolder<br>
 * <br>
 * Feature files should be placed in the same package as {@link HajpFunctionalTestSuite}<br>
 * <br>
 * To have new features enabled in testing, update:<br>
 * <br>
 * tags = {"@PluginInstall, @HotStandbyQueueBlock, @ClusterHAFunctional, <new tag>"} in {@link HajpFunctionalTestSuite}<br>
 * <br>
 * If tests fail, the application will exit with an exit code of 1.
 * TODO update javadoc when we fix the frame for all tests
 */
@Log4j2 public class HajpTestMain {

    public static void main(String[] args) {

        // create Options object
        Options options = new Options();
        addOption(options, "deploy", "Deploy folder", true);

        CommandLineParser parser = new GnuParser();
        CommandLine cmd = null;
        try {
            cmd = parser.parse(options, args);
        } catch (ParseException e) {
            usage(options);
            throw new RuntimeException(e);
        }

        setEnvironmentProperties(cmd);

        log.info("Starting HAJP Functional Tests...");
        Computer computer = new Computer();

        JUnitCore jUnitCore = new JUnitCore();
        jUnitCore.addListener(new ExecutionListener());
        List<Class> classList = new ArrayList<Class>();
        // add all test cases here
        classList.add(HajpFunctionalTestSuite.class);
        classList.add(HajpClusterFunctionalTestSuite.class);
        Result result = jUnitCore.run(computer, classList.toArray(new Class[classList.size()]));

        if (!result.wasSuccessful()) {
            log.error("Error: Tests failed!");
            System.exit(1);
        }

    }

    private static void setEnvironmentProperties(CommandLine cmd) {

        EnvironmentUtil.deploy = getOptionValue(cmd, "deploy");
        log.info("deploy: " + EnvironmentUtil.deploy);
    }

    private static String getOptionValue(CommandLine cmd, String optionName) {
        String value = "";
        if (cmd.hasOption(optionName)) {
            value = cmd.getOptionValue(optionName);
        }
        return value;
    }

    private static void addOption(Options options, String name, String description,
        boolean required) {
        Option opt = new Option(name, null, true, description);
        opt.setRequired(required);
        options.addOption(opt);
    }

    private static void usage(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        String header = "HAJP Tester\n" + "This application runs all HAJP Functional Tests\n";
        String footer = "";
        formatter.printHelp("hajp-test", header, options, footer, true);
    }
}
