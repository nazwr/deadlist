Feature: Show metadata extraction
  The Client should fetch show information from archive.org API
  And the Show class should properly extract and store metadata

  Scenario: Successfully fetch show metadata from API
    Given a valid show ID "gd1977-05-08.sbd.hicks.4136.sbeok.shnf"
    When the client queries the show info
    Then the response should include show metadata
    And the metadata should contain date information
    And the metadata should contain venue information
    And the metadata should contain location information
    And the metadata should contain files list

  Scenario: Invalid show ID returns error
    Given an invalid show ID "invalid-show-id-12345"
    When the client queries the show info with error handling
    Then it should raise an error about invalid show ID

  Scenario: API request fails
    Given a show ID that causes API failure
    When the client queries the show info with error handling
    Then it should raise an error about API request failure

  Scenario: Show initializes with correct metadata
    Given a show with valid metadata
    When a Show object is created with id "gd1977-05-08" and format "mp3"
    Then the show name should be formatted correctly
    And the show should have date set
    And the show should have venue set
    And the show should have location set
    And the show should have duration set
    And the show should have transferred_by set

  Scenario: Show has no files in requested format
    Given a show with metadata but no mp3 files
    When a Show object is created with id "gd1977-05-08" and format "mp3"
    Then the show should have an empty tracks list
