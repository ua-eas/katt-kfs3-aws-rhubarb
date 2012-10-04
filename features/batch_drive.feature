Feature: The batch_drive binary

  In order to drive batch
  A user should be able to run batch_drive.

  Background:
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed

  Scenario: drive a single job that succeeds
    When I kick off the batch driver with "einvoice" and "clearCacheJob"
    And  the batch invoker removes the runfile
    And  the batch invoker drops a successful statusfile in the history directory
    And  the command returns
    Then the command should return successfully
    And  I should not see anything on stderr
    And  I should see /Waiting for.*clearCacheJob/ in "logs/einvoice.log"
    And  I should see /Statusfile found.*clearCacheJob/ in "logs/einvoice.log"
    And  I should see /clearCacheJob.*succeeded/ in "logs/einvoice.log"
    And  I should see /Waiting for.*clearCacheJob/ in stdout
    And  I should see /Statusfile found.*clearCacheJob/ in stdout
    And  I should see /clearCacheJob.*succeeded/ in stdout

  Scenario: drive a single job that fails
    When I kick off the batch driver with "shipping" and "clearCacheJob"
    And  the batch invoker removes the runfile
    And  the batch invoker drops a failed statusfile in the history directory
    And  the command returns
    Then the command should return unsuccessfully
    And  I should not see anything on stderr
    And  I should see /Waiting for.*clearCacheJob/ in "logs/shipping.log"
    And  I should see /Statusfile found.*clearCacheJob/ in "logs/shipping.log"
    And  I should see /clearCacheJob.*did not succeed/ in "logs/shipping.log"
    And  I should see /Waiting for.*clearCacheJob/ in stdout
    And  I should see /Statusfile found.*clearCacheJob/ in stdout
    And  I should see /clearCacheJob.*did not succeed/ in stdout
