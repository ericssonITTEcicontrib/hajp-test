package com.ericsson.jenkinsci.hajp;

import org.junit.Test;

public class HajpTestMainTest {

    @Test(expected = RuntimeException.class)
    public void shouldThrowMissingOptionException() {
        String[] args = new String[] {};
        HajpTestMain.main(args);
    }

}
