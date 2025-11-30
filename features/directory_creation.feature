Feature: Directory creation and organization
  The CLI should create proper directory structure for downloads
  Shows should be organized in subdirectories

  Scenario: Create base shows directory
    Given a CLI instance with a show
    When directories are set up
    Then a "shows" directory should be created
    And the shows directory should exist in the current path

  Scenario: Create show-specific subdirectory
    Given a CLI instance with a show named "1977-05-08 - Barton Hall - Ithaca, NY"
    When directories are set up
    Then a subdirectory for the show should be created
    And the subdirectory should be named "1977-05-08 - Barton Hall - Ithaca, NY"

  Scenario: Return correct download path
    Given a CLI instance with a show
    When directories are set up
    Then the returned path should point to the show directory
    And the path should be absolute

  Scenario: Handle existing shows directory
    Given a "shows" directory already exists
    And a CLI instance with a show
    When directories are set up
    Then it should not raise an error
    And the existing directory should remain

  Scenario: Handle existing show subdirectory
    Given a show subdirectory already exists
    And a CLI instance with a show
    When directories are set up
    Then it should not raise an error
    And the existing show directory should remain

  Scenario: Custom base path
    Given a CLI instance with a show
    When directories are set up with custom base path "/tmp/custom"
    Then directories should be created under the custom path
    And the path should contain "/tmp/custom/shows"

  Scenario: Show name with special characters
    Given a CLI instance with a show named "1977-05-08 - O'Keefe Centre - Toronto, ON"
    When directories are set up
    Then the directory should be created successfully
    And the directory name should preserve special characters
