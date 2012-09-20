Feature: The batch_log binary

  In order to log lines to a job stream log file,
  A user should be able to run batch_log.

  Background:
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed

  Scenario Outline: log a simple INFO line
    When I run the command "bin/batch_log <Command>"
    Then the command should return successfully
    And I should not see anything on stdout
    And I should not see anything on stderr
    And I should see "<Level>" in "logs/einvoice.log"

    Examples:
      | Command                            | Level |
      | debug einvoice This is a log line. | DEBUG |
      | info einvoice This is a log line.  | INFO  |
      | warn einvoice This is a log line.  | WARN  |
      | error einvoice This is a log line. | ERROR |
