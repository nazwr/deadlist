Feature: Download functionality
  The Downloader should correctly download tracks and handle errors
  Files should be saved with proper naming conventions

  Scenario: Construct download URL for show
    Given a downloader for show "gd1977-05-08"
    When the download URL is generated
    Then the URL should be "https://archive.org/download/gd1977-05-08/"

  Scenario: File naming convention
    Given a downloader with path "/tmp/shows/barton-hall" and format "mp3"
    And a track with position "1", title "New Minglewood Blues", and filename "track01.mp3"
    When the file is downloaded
    Then the file should be saved as "1 -- New Minglewood Blues.mp3"

  Scenario: File naming with special characters in title
    Given a downloader with path "/tmp/shows/test" and format "flac"
    And a track with position "5", title "Me & My Uncle > Big River", and filename "track05.flac"
    When the file is downloaded
    Then the file should be saved as "5 -- Me & My Uncle > Big River.flac"

  Scenario: Download URL combines base and filename
    Given a downloader for show "gd1977-05-08"
    And a track with filename "gd77-05-08d1t01.mp3"
    When the download URL is constructed
    Then the full URL should be "https://archive.org/download/gd1977-05-08/gd77-05-08d1t01.mp3"

  Scenario: Downloader initialized with correct attributes
    Given a downloader with path "/tmp/test" and format "ogg"
    Then the downloader should have path "/tmp/test"
    And the downloader should have format "ogg"

  Scenario: Only HTTPS URLs are allowed
    Given a downloader with a non-HTTP URL
    When attempting to download
    Then it should raise an ArgumentError about HTTP URLs

  Scenario: Handle download errors gracefully
    Given a downloader with an invalid track URL
    When attempting to download
    Then it should catch the error
    And it should display an error message with track title

  Scenario: Multiple tracks download to same directory
    Given a downloader with path "/tmp/shows/test-show" and format "mp3"
    And multiple tracks to download
    When all tracks are downloaded
    Then all files should be in the same directory
    And each file should have a unique name based on position
