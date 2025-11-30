Feature: End-to-end CLI integration
  The CLI should orchestrate the full download flow
  From argument parsing through to file downloads

  Scenario: Complete successful download flow
    Given I have valid arguments "--id gd1977-05-08 --format mp3"
    When I run the DeadList CLI
    Then it should display the startup banner
    And it should parse the arguments successfully
    And it should create a show with metadata
    And it should set up the directory structure
    And it should initiate the download process
    And the process should complete without errors

  Scenario: Full flow with invalid show ID
    Given I have arguments with invalid show ID "--id invalid-123 --format mp3"
    When I run the DeadList CLI
    Then it should display the startup banner
    And it should parse the arguments successfully
    And it should fail during show creation
    And it should display a scraping error message
    And the process should not crash

  Scenario: Full flow with missing required arguments
    Given I have incomplete arguments "--format mp3"
    When I run the DeadList CLI with error handling
    Then it should exit during argument parsing
    And it should display an error about missing --id
    And it should not proceed to show creation

  Scenario: DeadList run method orchestrates correctly
    Given a DeadList instance
    And I mock the CLI flow
    When I call the run method
    Then it should create a CLI session
    And it should call create_show on the session
    And it should call download_show on the session
    And all steps should execute in order

  Scenario: CLI displays startup banner
    Given I initialize a CLI with valid arguments
    Then it should display the Grateful Dead banner
    And the banner should contain "One man gathers what another man spills"

  Scenario: Full flow with network error during download
    Given I have valid arguments "--id gd1977-05-08 --format mp3"
    And the download will fail with network error
    When I run the DeadList CLI
    Then it should display the startup banner
    And it should create the show successfully
    And it should fail during download
    And it should display a download error message
    And the process should not crash

  Scenario: Full flow creates proper directory structure
    Given I have valid arguments "--id gd1977-05-08 --format flac"
    When I run the DeadList CLI with directory tracking
    Then it should create the shows directory
    And it should create a show-specific subdirectory
    And the directory name should match the show name

  Scenario: Complete flow with no files in requested format
    Given I have valid arguments "--id gd1977-05-08 --format ogg"
    And the show has no ogg files available
    When I run the DeadList CLI
    Then it should display the startup banner
    And it should create the show successfully
    And it should display "No ogg files found" message
    And the process should complete without downloads
