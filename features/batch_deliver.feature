Feature: The batch_deliver binary

  In order to deliver batch reports
  A user should be able to run batch_deliver.

  Background:
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed

  Scenario Outline: deliver a batch report
    When I run the command "bin/batch_deliver <JobStream> <Report> --test"
    Then the command should return successfully
    And  I should not see anything on stderr
    And  a report should be fake delivered to "srawlins@email.arizona.edu"

    Examples:
      | JobStream | Report |
      | archibus  | report |
