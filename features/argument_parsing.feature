Feature: Argument parsing
  DeadList should properly parse command-line arguments
  And validate required parameters before executing

  Scenario: Valid arguments are provided
    Given valid arguments with id "gd1977-05-08.sbd.hicks.4136.sbeok.shnf" and format "mp3"
    When the arguments are parsed
    Then the parsed parameters should include the id
    And the parsed parameters should include the format

  Scenario: Missing required --id argument
    Given arguments with only format "mp3"
    When the arguments are parsed with error handling
    Then it should exit with an error about missing --id

  Scenario: Missing required --format argument
    Given arguments with only id "gd1977-05-08.sbd.hicks.4136.sbeok.shnf"
    When the arguments are parsed with error handling
    Then it should exit with an error about missing --format

  Scenario: Both required arguments are missing
    Given no arguments are provided
    When the arguments are parsed with error handling
    Then it should exit with an error about missing required arguments

  Scenario: Format is case-insensitive
    Given valid arguments with id "gd1977-05-08.sbd.hicks.4136.sbeok.shnf" and format "MP3"
    When the arguments are parsed
    Then the format should be converted to lowercase

  Scenario: --help flag shows usage
    Given the --help flag is provided
    When the arguments are parsed with exit handling
    Then it should display the usage banner

  Scenario: --version flag shows version
    Given the --version flag is provided
    When the arguments are parsed with exit handling
    Then it should display the version number

  Scenario: Invalid option is rejected
    Given arguments with invalid option "--invalid-flag"
    When the arguments are parsed with error handling
    Then it should exit with an error about invalid option
