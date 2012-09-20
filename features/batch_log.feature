Feature: The batch_log binary

  In order to log lines to a job stream log file,
  A user should be able to run batch_log.

  Background:
    Given BATCH_HOME is "spec/live/uaf-stg"

  Scenario Outline: log a simple INFO line
    When I run the command "bin/batch_log <Command>"
    Then the command should return successfully
    And I should not see anything on stdout
    And I should not see anything on stderr

    Examples:
      | Command                            |
      | debug einvoice This is a log line. |
      | info einvoice This is a log line.  |
      | warn einvoice This is a log line.  |
      | error einvoice This is a log line. |
