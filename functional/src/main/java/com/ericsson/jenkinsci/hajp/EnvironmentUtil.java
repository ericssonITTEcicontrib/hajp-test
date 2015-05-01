package com.ericsson.jenkinsci.hajp;

import lombok.extern.log4j.Log4j2;

import java.io.File;
import java.io.IOException;

/**
 * Utility class for maintaining the information of testing environment.
 */
@Log4j2 public class EnvironmentUtil {

    /**
     * the name of shell script file which restarts the testing environment, i.e., docker containers.
     */
    public final static String RUN_SCRIPT_FILENAME = "runScript.sh";

    /**
     * the path of deploy folder
     */
    public static String deploy;

    /**
     * clean up the testing environment.
     *
     * @throws IOException
     */
    public static void cleanUp() throws IOException {
        log.info("===============================cleanUp========================================");
        File shellFile = new File(deploy, RUN_SCRIPT_FILENAME);
        if (!shellFile.exists() || !shellFile.canExecute()) {
            throw new RuntimeException(
                "check the file (not existing or not executable): " + shellFile.getAbsolutePath());
        }
        ShellUtil.run(shellFile.getAbsolutePath());
        HajpEnvironmentSetup.getIPs();
    }

}
