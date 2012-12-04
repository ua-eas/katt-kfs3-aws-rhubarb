Feature: The batch_archive binary

  In order to archive batch files
  A user should be able to run batch_archive.

  Background:
    Given BATCH_HOME is "spec/live/uaf-stg"
    And the live directory is cleansed

  Scenario Outline: drive a single job that succeeds
    When I run the command "bin/batch_archive <Directory>"
    Then the command should return successfully
    And  I should not see anything on stderr
    And  I should see /Rhubarb::Archivist initialized with directory name = '<Directory>'/ in "logs/archivist.log"
    And  I should see /archiving following files in `<Directory>`:/ in "logs/archivist.log"
    And  I should see /archiving following files in `<Directory>`:/ in stdout

    Examples:
      | Directory                      |
      | purap/electronicInvoice/accept |
      | pdp/shipping                   |
