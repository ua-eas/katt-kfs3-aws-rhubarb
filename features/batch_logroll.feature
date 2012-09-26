Feature: The batch_logroll binary

  In order to roll the job stream logs,
  A user should be able to run batch_logroll.

  Scenario: roll logs once
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed
    When I log something for "einvoice"
    And  I log something for "shipping"
    And  I run the command "bin/batch_logroll"
    Then the command should return successfully
    And I should not see anything on stdout
    And I should not see anything on stderr
    And I should see no logs in the logs directory
    And I should see a log in the "einvoice" log archive directory
    And I should see a log in the "shipping" log archive directory

  Scenario: roll logs on consecutive days
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed

    And  the time is "19:00:00" on "2012-09-01"
    When I log something for "einvoice"
    And  I log something for "shipping"
    And  now the time is "06:00:00" on "2012-09-02"
    And  I pretend to run the command "batch_logroll"

    And  now the time is "19:00:00" on "2012-09-02"
    And  I log something for "einvoice"
    And  I log something for "shipping"
    And  now the time is "06:00:00" on "2012-09-03"
    And  I pretend to run the command "batch_logroll"

    Then the command should return successfully
    And I should not see anything on stdout
    And I should not see anything on stderr
    And I should see no logs in the logs directory
    And I should see 2 logs in the "einvoice" log archive directory
    And I should see 2 logs in the "shipping" log archive directory
