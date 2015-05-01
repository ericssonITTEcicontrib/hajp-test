package com.ericsson.jenkinsci.hajp;

import lombok.extern.log4j.Log4j2;
import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.PumpStreamHandler;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

/**
 * Utility class for shell command
 */
@Log4j2 public class ShellUtil {
    /**
     * run the shell command
     *
     * @param command the command to run
     * @return the result stored in a {@link ShellResult} object
     * @throws IOException execution of subprocess failed or the subprocess returned a exit value indicating a failure
     */
    public static ShellResult run(String command) throws IOException {

        log.info("running shell command: " + command);

        ShellResult result = new ShellResult();

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        CommandLine commandline = CommandLine.parse(command);
        DefaultExecutor exec = new DefaultExecutor();
        PumpStreamHandler streamHandler = new PumpStreamHandler(outputStream);
        exec.setStreamHandler(streamHandler);
        result.exitValue = exec.execute(commandline);
        log.debug("Process exitValue: " + result.exitValue);
        result.output = outputStream.toString();

        log.debug("<OUTPUT>");
        log.debug(result.output);
        log.debug("</OUTPUT>");

        return result;
    }

    /**
     * represent the result of running a shell command with the exit value and the output
     */
    public static class ShellResult {
        public int exitValue;
        public String output;
    }
}
