Feature: Multiple shows download
DeadList should handle downloading multiple shows at once
Using comma-separated IDs with graceful error handling

Scenario: Parse comma-separated show IDs
    Given valid arguments with ids "gd1977-05-08,gd1978-05-05" and format "mp3"
    When the arguments are parsed
    Then the parsed parameters should include 2 show IDs

Scenario: Download multiple shows successfully
    Given valid arguments with ids "show1,show2" and format "mp3"
    When the shows are downloaded
    Then both shows should be processed sequentially
    And progress should be displayed for each show

Scenario: Handle format mismatch gracefully
    Given valid arguments with ids "show-with-mp3,show-without-mp3" and format "mp3"
    When the shows are downloaded with format mismatch
    Then the first show should download successfully
    And the second show should display format error with available formats
    And the second show should be skipped