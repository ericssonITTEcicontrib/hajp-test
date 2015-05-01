
# HAJP Test Application

**This application is designed to setup the HAJP Environment and run Functional Tests**

To build:

* mvn clean package

To run:

Usage: runScript.sh [options]

Options:
  --runtests (optional) : Once docker containers are running, execute the hajp-test suite
  --testjar <location of hajp-test.jar (optional) : Defaults to ../target/hajp-test.jar
  --coreversion <version> (optional) : version of core to use (leave empty for latest release, or specify SNAPSHOT)
  --monitorversion <version> (optional) : version of monitor to use (leave empty for latest release, or specify SNAPSHOT)
  --orchestratorversion <version> (optional) : version of orchestrator to use (leave empty for latest release, or specify SNAPSHOT)
  --verbose : enable verbose logging

Example command:

* runScript.sh --runtests --coreversion=SNAPSHOT

This take the latest release versions for monitor and orchestrator and uses the SNAPSHOT version core
and runs the tests.

Example Tests:

* Please see TestDummyFeature.java for how to obtain setup information

TODO:

- add junit listener to create test reports on disk

