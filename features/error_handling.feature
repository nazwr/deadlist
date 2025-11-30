Feature: Error handling
  The application should handle errors gracefully
  Users should receive clear error messages

  Scenario: Invalid show ID from user input
    Given an ArgumentParser with show ID "invalid-show-123"
    When the client attempts to fetch show info
    Then it should raise an invalid show error
    And the error message should mention "invalid-show-123"

  Scenario: Network timeout during API request
    Given a show ID that causes network timeout
    When the client attempts to fetch show info
    Then it should raise an error about failed request
    And the error message should be user-friendly

  Scenario: Malformed JSON response from API
    Given an API response with malformed JSON
    When the client attempts to parse the response
    Then it should raise an error about failed fetch
    And the error should be caught gracefully

  Scenario: Show ID extraction from invalid URL
    Given an invalid archive.org URL "https://example.com/invalid"
    When the CLI extracts the show ID
    Then it should return the original input
    And not raise an error

  Scenario: Show ID extraction from valid URL
    Given a valid archive.org URL "https://archive.org/details/gd1977-05-08"
    When the CLI extracts the show ID
    Then it should return "gd1977-05-08"

  Scenario: Missing metadata fields in API response
    Given an API response missing some metadata fields
    When a show is created from the response
    Then it should handle nil values gracefully
    And the show should still be created

  Scenario: Empty files array from API
    Given an API response with empty files array
    When a show is created with format "mp3"
    Then the tracks array should be empty
    And no error should be raised

  Scenario: CLI handles show creation failure
    Given a CLI instance with invalid arguments
    When create_show is called
    Then it should catch the error and not crash
    And display a user-friendly error message
    And not crash the application

  Scenario: CLI handles download failure
    Given a CLI instance with a valid show
    When download fails due to network error
    Then it should catch the error and not crash
    And display download failed message
    And not crash the application

  Scenario: Directory creation with permission error
    Given a base path without write permissions
    When directories are set up with permission error
    Then it should catch the permission error
    And display directory creation failed message
