package com.ericsson.jenkinsci.hajp;

import lombok.extern.log4j.Log4j2;
import org.apache.commons.validator.routines.InetAddressValidator;

import java.io.IOException;

/**
 * Simple class that holds HAJP environment info.
 */
@Log4j2 public class HajpEnvironmentSetup {

    // those constants depend on the script "runScript.sh"
    private final static String ORCHESTRATOR = "orchestrator";
    private final static String MONITOR = "monitor";
    private final static String CORE1 = "core1";
    private final static String CORE2 = "core2";

    // fixed port for all roles in the cluster
    private final static String PORT = "2551";

    private final static InetAddressValidator inetAddressValidator = new InetAddressValidator();

    //self-explanatory
    public static String orchestratorAddress;
    public static String orchestratorPort = PORT;
    public static String monitorAddress;
    public static String monitorPort = PORT;
    public static String masterOneAddress;
    public static String masterOnePort = PORT;
    public static String masterTwoAddress;
    public static String masterTwoPort = PORT;

    /**
     * get the IPs of the roles in the hajp clusters (by running shell command).
     *
     * @throws IOException if running the shell causes some error.
     */
    public static void getIPs() throws IOException {

        orchestratorAddress = getIP(ORCHESTRATOR);
        log.info("orchestrator: " + orchestratorAddress + ":" + orchestratorPort);

        monitorAddress = getIP(MONITOR);
        log.info("monitor: " + monitorAddress + ":" + monitorPort);

        masterOneAddress = getIP(CORE1);
        log.info("core1: " + masterOneAddress + ":" + masterOnePort);

        masterTwoAddress = getIP(CORE2);
        log.info("core2: " + masterTwoAddress + ":" + masterTwoPort);

    }

    private static String getIP(String name) throws IOException {

        String command = "docker inspect --format '{{ .NetworkSettings.IPAddress }}' " + name;

        ShellUtil.ShellResult result = ShellUtil.run(command);
        // the output of the shell is sth. like this: "1.1.1.1\n" with quotes
        String ip = result.output.trim().replace("\"", "");
        if (!inetAddressValidator.isValidInet4Address(ip)) {
            throw new RuntimeException("not a valid ip: " + ip);
        }

        return ip;
    }

    /**
     * get the url of master {@code arg1}
     *
     * @param arg1
     * @return the url of master {@code arg1}
     */
    public static String getUrlForMaster(int arg1) {
        if (arg1 == 1) {
            return "http://" + masterOneAddress + ":8080";
        }
        if (arg1 == 2) {
            return "http://" + masterTwoAddress + ":8080";
        }
        throw new RuntimeException("invalid index of masters");
    }

    /**
     * get the IP of master {@code arg1}
     *
     * @param arg1
     * @return the IP of master {@code arg1}
     */
    public static String getMasterAddress(int arg1) {
        if (arg1 == 1) {
            return masterOneAddress;
        }
        if (arg1 == 2) {
            return masterTwoAddress;
        }
        throw new RuntimeException("invalid index of masters");
    }

    /**
     * get the port of master {@code arg1}
     *
     * @param arg1
     * @return the port of master {@code arg1}
     */
    public static String getPortOfMaster(int arg1) {
        if (arg1 == 1) {
            return HajpEnvironmentSetup.masterOnePort;
        }
        if (arg1 == 2) {
            return HajpEnvironmentSetup.masterTwoPort;
        }
        throw new RuntimeException("invalid index of masters");
    }

}
