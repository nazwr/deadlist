Feature: Track filtering by audio format
  The Show class should filter tracks by requested audio format
  And create Track objects only for matching files

  Scenario: Filter tracks by mp3 format
    Given a show with mixed audio formats
    When the show is initialized with format "mp3"
    Then only mp3 tracks should be included
    And non-mp3 files should be excluded

  Scenario: Filter tracks by flac format
    Given a show with mixed audio formats
    When the show is initialized with format "flac"
    Then only flac tracks should be included
    And non-flac files should be excluded

  Scenario: Filter tracks by ogg format
    Given a show with ogg and mp3 files
    When the show is initialized with format "ogg"
    Then only ogg tracks should be included

  Scenario: Filter tracks by m4a format
    Given a show with m4a and flac files
    When the show is initialized with format "m4a"
    Then only m4a tracks should be included

  Scenario: Case-insensitive format matching
    Given a show with files having uppercase extensions
    When the show is initialized with format "mp3"
    Then tracks with .MP3 extension should be included
    And tracks with .Mp3 extension should be included

  Scenario: Non-audio files are excluded
    Given a show with audio and non-audio files
    When the show is initialized with format "mp3"
    Then only audio files should be in tracks
    And text files should be excluded
    And image files should be excluded

  Scenario: Track object has correct attributes
    Given a show with properly formatted track data
    When tracks are created
    Then each track should have a position
    And each track should have a title
    And each track should have a filename

  Scenario: Track uses index when track number missing
    Given a show with files missing track numbers
    When tracks are created
    Then tracks should use sequential index as position

  Scenario: Multiple tracks in correct order
    Given a show with 5 mp3 tracks
    When the show is initialized with format "mp3"
    Then there should be 5 tracks
    And tracks should be in sequential order

  Scenario: Unsupported audio formats are excluded
    Given a show with supported and unsupported audio formats
    When the show is initialized with format "mp3"
    Then only supported format files should be included
    And unsupported audio formats should be excluded

  Scenario: All files are unsupported formats
    Given a show with only unsupported audio formats
    When the show is initialized with format "mp3"
    Then the show should have an empty tracks list
